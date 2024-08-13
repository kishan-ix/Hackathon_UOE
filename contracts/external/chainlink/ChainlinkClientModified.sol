// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Chainlink.sol";
import "./interfaces/ChainlinkRequestInterface.sol";
import "./interfaces/ENSInterface.sol";
import "./interfaces/LinkTokenInterface.sol";
import "./interfaces/OperatorInterface.sol";
import "./interfaces/PointerInterface.sol";
import {ENSResolver as ENSResolver_Chainlink} from "./vendor/ENSResolver.sol";

abstract contract ChainlinkClientModified {
    using Chainlink for Chainlink.Request;

    uint256 internal constant LINK_DIVISIBILITY = 10 ** 18;
    uint256 private constant AMOUNT_OVERRIDE = 0;
    address private constant SENDER_OVERRIDE = address(0);
    uint256 private constant ORACLE_ARGS_VERSION = 1;
    uint256 private constant OPERATOR_ARGS_VERSION = 2;
    bytes32 private constant ENS_TOKEN_SUBNAME = keccak256("link");
    bytes32 private constant ENS_ORACLE_SUBNAME = keccak256("oracle");
    address private constant LINK_TOKEN_POINTER =
        0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

    ENSInterface private s_ens;
    bytes32 private s_ensNode;
    LinkTokenInterface private s_link;
    OperatorInterface private s_oracle;
    uint256 private s_requestCount;
    mapping(bytes32 => address) private s_pendingRequests;

    event ChainlinkRequested(bytes32 indexed id);
    event ChainlinkFulfilled(bytes32 indexed id);
    event ChainlinkCancelled(bytes32 indexed id);

    function init() internal {
        s_requestCount = 1;
    }

    function buildChainlinkRequest(
        bytes32 specId,
        address callbackAddr,
        bytes4 callbackFunctionSignature
    ) internal pure returns (Chainlink.Request memory) {
        Chainlink.Request memory req;
        return req.initialize(specId, callbackAddr, callbackFunctionSignature);
    }

    function buildOperatorRequest(
        bytes32 specId,
        bytes4 callbackFunctionSignature
    ) internal view returns (Chainlink.Request memory) {
        Chainlink.Request memory req;
        return req.initialize(specId, address(this), callbackFunctionSignature);
    }

    function sendChainlinkRequest(
        Chainlink.Request memory req,
        uint256 payment
    ) internal returns (bytes32) {
        return sendChainlinkRequestTo(address(s_oracle), req, payment);
    }

    function sendChainlinkRequestTo(
        address oracleAddress,
        Chainlink.Request memory req,
        uint256 payment
    ) internal returns (bytes32 requestId) {
        uint256 nonce = s_requestCount;
        s_requestCount = nonce + 1;
        bytes memory encodedRequest = abi.encodeWithSelector(
            ChainlinkRequestInterface.oracleRequest.selector,
            SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
            AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
            req.id,
            address(this),
            req.callbackFunctionId,
            nonce,
            ORACLE_ARGS_VERSION,
            req.buf.buf
        );
        return _rawRequest(oracleAddress, nonce, payment, encodedRequest);
    }

    function sendOperatorRequest(
        Chainlink.Request memory req,
        uint256 payment
    ) internal returns (bytes32) {
        return sendOperatorRequestTo(address(s_oracle), req, payment);
    }

    function sendOperatorRequestTo(
        address oracleAddress,
        Chainlink.Request memory req,
        uint256 payment
    ) internal returns (bytes32 requestId) {
        uint256 nonce = s_requestCount;
        s_requestCount = nonce + 1;
        bytes memory encodedRequest = abi.encodeWithSelector(
            OperatorInterface.operatorRequest.selector,
            SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
            AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
            req.id,
            req.callbackFunctionId,
            nonce,
            OPERATOR_ARGS_VERSION,
            req.buf.buf
        );
        return _rawRequest(oracleAddress, nonce, payment, encodedRequest);
    }

    function _rawRequest(
        address oracleAddress,
        uint256 nonce,
        uint256 payment,
        bytes memory encodedRequest
    ) private returns (bytes32 requestId) {
        requestId = keccak256(abi.encodePacked(this, nonce));
        s_pendingRequests[requestId] = oracleAddress;
        emit ChainlinkRequested(requestId);
        require(
            s_link.transferAndCall(oracleAddress, payment, encodedRequest),
            "unable to transferAndCall to oracle"
        );
    }

    function cancelChainlinkRequest(
        bytes32 requestId,
        uint256 payment,
        bytes4 callbackFunc,
        uint256 expiration
    ) internal {
        OperatorInterface requested = OperatorInterface(
            s_pendingRequests[requestId]
        );
        delete s_pendingRequests[requestId];
        emit ChainlinkCancelled(requestId);
        requested.cancelOracleRequest(
            requestId,
            payment,
            callbackFunc,
            expiration
        );
    }

    function getNextRequestCount() internal view returns (uint256) {
        return s_requestCount;
    }

    function setChainlinkOracle(address oracleAddress) internal {
        s_oracle = OperatorInterface(oracleAddress);
    }

    function setChainlinkToken(address linkAddress) internal {
        s_link = LinkTokenInterface(linkAddress);
    }

    function setPublicChainlinkToken() internal {
        setChainlinkToken(PointerInterface(LINK_TOKEN_POINTER).getAddress());
    }

    function chainlinkTokenAddress() internal view returns (address) {
        return address(s_link);
    }

    function chainlinkOracleAddress() internal view returns (address) {
        return address(s_oracle);
    }

    function addChainlinkExternalRequest(
        address oracleAddress,
        bytes32 requestId
    ) internal notPendingRequest(requestId) {
        s_pendingRequests[requestId] = oracleAddress;
    }

    function useChainlinkWithENS(address ensAddress, bytes32 node) internal {
        s_ens = ENSInterface(ensAddress);
        s_ensNode = node;
        bytes32 linkSubnode = keccak256(
            abi.encodePacked(s_ensNode, ENS_TOKEN_SUBNAME)
        );
        ENSResolver_Chainlink resolver = ENSResolver_Chainlink(
            s_ens.resolver(linkSubnode)
        );
        setChainlinkToken(resolver.addr(linkSubnode));
        updateChainlinkOracleWithENS();
    }

    function updateChainlinkOracleWithENS() internal {
        bytes32 oracleSubnode = keccak256(
            abi.encodePacked(s_ensNode, ENS_ORACLE_SUBNAME)
        );
        ENSResolver_Chainlink resolver = ENSResolver_Chainlink(
            s_ens.resolver(oracleSubnode)
        );
        setChainlinkOracle(resolver.addr(oracleSubnode));
    }

    function validateChainlinkCallback(
        bytes32 requestId
    )
        internal
        recordChainlinkFulfillment(requestId)
    // solhint-disable-next-line no-empty-blocks
    {

    }

    modifier recordChainlinkFulfillment(bytes32 requestId) {
        require(
            msg.sender == s_pendingRequests[requestId],
            "Source must be the oracle of the request"
        );
        delete s_pendingRequests[requestId];
        emit ChainlinkFulfilled(requestId);
        _;
    }

    modifier notPendingRequest(bytes32 requestId) {
        require(
            s_pendingRequests[requestId] == address(0),
            "Request is already pending"
        );
        _;
    }
}

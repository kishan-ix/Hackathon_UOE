// SPDX-License-Identifier: MIT
/**
 *Submitted for verification at Etherscan.io on 2023-03-14
 */

// File: .deps/npm/@chainlink/contracts/src/v0.7/vendor/SafeMathChainlink.sol

pragma solidity ^0.7.0;

library SafeMathChainlink {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: .deps/npm/@chainlink/contracts/src/v0.7/vendor/Address.sol

// From https://github.com/OpenZeppelin/openzeppelin-contracts v3.4.0(fa64a1ced0b70ab89073d5d0b6e01b0778f7e7d6)

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.7.0;

interface WithdrawalInterface {

    function withdraw(address recipient, uint256 amount) external;

    /**
     * @notice query the available amount of LINK to withdraw by msg.sender
     */
    function withdrawable() external view returns (uint256);
}

pragma solidity ^0.7.0;

interface OracleInterface {
    function fulfillOracleRequest(
        bytes32 requestId,
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 expiration,
        bytes32 data
    ) external returns (bool);

    function withdraw(address recipient, uint256 amount) external;

    function withdrawable() external view returns (uint256);
}

pragma solidity ^0.7.0;

interface ChainlinkRequestInterface {
    function oracleRequest(
        address sender,
        uint256 requestPrice,
        bytes32 serviceAgreementID,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 nonce,
        uint256 dataVersion,
        bytes calldata data
    ) external;

    function cancelOracleRequest(
        bytes32 requestId,
        uint256 payment,
        bytes4 callbackFunctionId,
        uint256 expiration
    ) external;
}

pragma solidity ^0.7.0;

interface OperatorInterface is ChainlinkRequestInterface, OracleInterface {
    function operatorRequest(
        address sender,
        uint256 payment,
        bytes32 specId,
        bytes4 callbackFunctionId,
        uint256 nonce,
        uint256 dataVersion,
        bytes calldata data
    ) external;

    function fulfillOracleRequest2(
        bytes32 requestId,
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 expiration,
        bytes calldata data
    ) external returns (bool);

    function ownerTransferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);
}

pragma solidity ^0.7.0;

interface LinkTokenInterface {
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256 remaining);

    function approve(
        address spender,
        uint256 value
    ) external returns (bool success);

    function balanceOf(address owner) external view returns (uint256 balance);

    function decimals() external view returns (uint8 decimalPlaces);

    function decreaseApproval(
        address spender,
        uint256 addedValue
    ) external returns (bool success);

    function increaseApproval(
        address spender,
        uint256 subtractedValue
    ) external;

    function name() external view returns (string memory tokenName);

    function symbol() external view returns (string memory tokenSymbol);

    function totalSupply() external view returns (uint256 totalTokensIssued);

    function transfer(
        address to,
        uint256 value
    ) external returns (bool success);

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);
}

pragma solidity ^0.7.0;

interface OwnableInterface {
    function owner() external returns (address);

    function transferOwnership(address recipient) external;

    function acceptOwnership() external;
}

pragma solidity ^0.7.0;

contract ConfirmedOwnerWithProposal is OwnableInterface {
    address private s_owner;
    address private s_pendingOwner;

    event OwnershipTransferRequested(address indexed from, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);

    constructor(address newOwner, address pendingOwner) {
        require(newOwner != address(0), "Cannot set owner to zero");

        s_owner = newOwner;
        if (pendingOwner != address(0)) {
            _transferOwnership(pendingOwner);
        }
    }


    function transferOwnership(address to) public override onlyOwner {
        _transferOwnership(to);
    }

    /**
     * @notice Allows an ownership transfer to be completed by the recipient.
     */
    function acceptOwnership() external override {
        require(msg.sender == s_pendingOwner, "Must be proposed owner");

        address oldOwner = s_owner;
        s_owner = msg.sender;
        s_pendingOwner = address(0);

        emit OwnershipTransferred(oldOwner, msg.sender);
    }

    /**
     * @notice Get the current owner
     */
    function owner() public view override returns (address) {
        return s_owner;
    }

    /**
     * @notice validate, transfer ownership, and emit relevant events
     */
    function _transferOwnership(address to) private {
        require(to != msg.sender, "Cannot transfer to self");

        s_pendingOwner = to;

        emit OwnershipTransferRequested(s_owner, to);
    }

    /**
     * @notice validate access
     */
    function _validateOwnership() internal view {
        require(msg.sender == s_owner, "Only callable by owner");
    }

    /**
     * @notice Reverts if called by anyone other than the contract owner.
     */
    modifier onlyOwner() {
        _validateOwnership();
        _;
    }
}

// File: .deps/npm/@chainlink/contracts/src/v0.7/ConfirmedOwner.sol

pragma solidity ^0.7.0;

contract ConfirmedOwner is ConfirmedOwnerWithProposal {
    constructor(
        address newOwner
    ) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// File: .deps/npm/@chainlink/contracts/src/v0.7/LinkTokenReceiver.sol

pragma solidity ^0.7.0;

abstract contract LinkTokenReceiver {

    function onTokenTransfer(
        address sender,
        uint256 amount,
        bytes memory data
    ) public validateFromLINK permittedFunctionsForLINK(data) {
        assembly {
            // solhint-disable-next-line avoid-low-level-calls
            mstore(add(data, 36), sender) // ensure correct sender is passed
            // solhint-disable-next-line avoid-low-level-calls
            mstore(add(data, 68), amount) // ensure correct amount is passed
        }
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = address(this).delegatecall(data); // calls oracleRequest
        require(success, "Unable to create request");
    }

    function getChainlinkToken() public view virtual returns (address);

    /**
     * @notice Validate the function called on token transfer
     */
    function _validateTokenTransferAction(
        bytes4 funcSelector,
        bytes memory data
    ) internal virtual;

    /**
     * @dev Reverts if not sent from the LINK token
     */
    modifier validateFromLINK() {
        require(msg.sender == getChainlinkToken(), "Must use LINK token");
        _;
    }

    modifier permittedFunctionsForLINK(bytes memory data) {
        bytes4 funcSelector;
        assembly {
            // solhint-disable-next-line avoid-low-level-calls
            funcSelector := mload(add(data, 32))
        }
        _validateTokenTransferAction(funcSelector, data);
        _;
    }
}

// File: .deps/npm/@chainlink/contracts/src/v0.7/interfaces/AuthorizedReceiverInterface.sol

pragma solidity ^0.7.0;

interface AuthorizedReceiverInterface {
    function isAuthorizedSender(address sender) external view returns (bool);

    function getAuthorizedSenders() external returns (address[] memory);

    function setAuthorizedSenders(address[] calldata senders) external;
}

// File: .deps/npm/@chainlink/contracts/src/v0.7/AuthorizedReceiver.sol

pragma solidity ^0.7.0;

abstract contract AuthorizedReceiver is AuthorizedReceiverInterface {
    mapping(address => bool) private s_authorizedSenders;
    address[] private s_authorizedSenderList;

    event AuthorizedSendersChanged(address[] senders, address changedBy);

    function setAuthorizedSenders(
        address[] calldata senders
    ) external override validateAuthorizedSenderSetter {
        require(senders.length > 0, "Must have at least 1 authorized sender");
        // Set previous authorized senders to false
        uint256 authorizedSendersLength = s_authorizedSenderList.length;
        for (uint256 i = 0; i < authorizedSendersLength; i++) {
            s_authorizedSenders[s_authorizedSenderList[i]] = false;
        }
        // Set new to true
        for (uint256 i = 0; i < senders.length; i++) {
            s_authorizedSenders[senders[i]] = true;
        }
        // Replace list
        s_authorizedSenderList = senders;
        emit AuthorizedSendersChanged(senders, msg.sender);
    }

    function getAuthorizedSenders()
        external
        view
        override
        returns (address[] memory)
    {
        return s_authorizedSenderList;
    }

    function isAuthorizedSender(
        address sender
    ) public view override returns (bool) {
        return s_authorizedSenders[sender];
    }

    function _canSetAuthorizedSenders() internal virtual returns (bool);

    /**
     * @notice validates the sender is an authorized sender
     */
    function _validateIsAuthorizedSender() internal view {
        require(isAuthorizedSender(msg.sender), "Not authorized sender");
    }

    /**
     * @notice prevents non-authorized addresses from calling this method
     */
    modifier validateAuthorizedSender() {
        _validateIsAuthorizedSender();
        _;
    }

    /**
     * @notice prevents non-authorized addresses from calling this method
     */
    modifier validateAuthorizedSenderSetter() {
        require(_canSetAuthorizedSenders(), "Cannot set authorized senders");
        _;
    }
}

// File: .deps/npm/@chainlink/contracts/src/v0.7/Operator.sol

pragma solidity ^0.7.0;

contract Operator is
    AuthorizedReceiver,
    ConfirmedOwner,
    LinkTokenReceiver,
    OperatorInterface,
    WithdrawalInterface
{
    using Address for address;
    using SafeMathChainlink for uint256;

    struct Commitment {
        bytes31 paramsHash;
        uint8 dataVersion;
    }

    uint256 public constant getExpiryTime = 5 minutes;
    uint256 private constant MAXIMUM_DATA_VERSION = 256;
    uint256 private constant MINIMUM_CONSUMER_GAS_LIMIT = 400000;
    uint256 private constant SELECTOR_LENGTH = 4;
    uint256 private constant EXPECTED_REQUEST_WORDS = 2;
    uint256 private constant MINIMUM_REQUEST_LENGTH =
        SELECTOR_LENGTH + (32 * EXPECTED_REQUEST_WORDS);
    // We initialize fields to 1 instead of 0 so that the first invocation
    // does not cost more gas.
    uint256 private constant ONE_FOR_CONSISTENT_GAS_COST = 1;
    // oracleRequest is intended for version 1, enabling single word responses
    bytes4 private constant ORACLE_REQUEST_SELECTOR =
        this.oracleRequest.selector;
    // operatorRequest is intended for version 2, enabling multi-word responses
    bytes4 private constant OPERATOR_REQUEST_SELECTOR =
        this.operatorRequest.selector;

    LinkTokenInterface internal immutable linkToken;
    mapping(bytes32 => Commitment) private s_commitments;
    mapping(address => bool) private s_owned;
    // Tokens sent for requests that have not been fulfilled yet
    uint256 private s_tokensInEscrow = ONE_FOR_CONSISTENT_GAS_COST;

    event OracleRequest(
        bytes32 indexed specId,
        address requester,
        bytes32 requestId,
        uint256 payment,
        address callbackAddr,
        bytes4 callbackFunctionId,
        uint256 cancelExpiration,
        uint256 dataVersion,
        bytes data
    );

    event CancelOracleRequest(bytes32 indexed requestId);

    event OracleResponse(bytes32 indexed requestId);

    event OwnableContractAccepted(address indexed acceptedContract);

    event TargetsUpdatedAuthorizedSenders(
        address[] targets,
        address[] senders,
        address changedBy
    );

    constructor(address link, address owner) ConfirmedOwner(owner) {
        linkToken = LinkTokenInterface(link); // external but already deployed and unalterable
    }

    function typeAndVersion() external pure virtual returns (string memory) {
        return "Operator 1.0.0";
    }

    function oracleRequest(
        address sender,
        uint256 payment,
        bytes32 specId,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 nonce,
        uint256 dataVersion,
        bytes calldata data
    ) external override validateFromLINK {
        (
            bytes32 requestId,
            uint256 expiration
        ) = _verifyAndProcessOracleRequest(
                sender,
                payment,
                callbackAddress,
                callbackFunctionId,
                nonce,
                dataVersion
            );
        emit OracleRequest(
            specId,
            sender,
            requestId,
            payment,
            sender,
            callbackFunctionId,
            expiration,
            dataVersion,
            data
        );
    }

    function operatorRequest(
        address sender,
        uint256 payment,
        bytes32 specId,
        bytes4 callbackFunctionId,
        uint256 nonce,
        uint256 dataVersion,
        bytes calldata data
    ) external override validateFromLINK {
        (
            bytes32 requestId,
            uint256 expiration
        ) = _verifyAndProcessOracleRequest(
                sender,
                payment,
                sender,
                callbackFunctionId,
                nonce,
                dataVersion
            );
        emit OracleRequest(
            specId,
            sender,
            requestId,
            payment,
            sender,
            callbackFunctionId,
            expiration,
            dataVersion,
            data
        );
    }

    function fulfillOracleRequest(
        bytes32 requestId,
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 expiration,
        bytes32 data
    )
        external
        override
        validateAuthorizedSender
        validateRequestId(requestId)
        validateCallbackAddress(callbackAddress)
        returns (bool)
    {
        _verifyOracleRequestAndProcessPayment(
            requestId,
            payment,
            callbackAddress,
            callbackFunctionId,
            expiration,
            1
        );
        emit OracleResponse(requestId);
        require(
            gasleft() >= MINIMUM_CONSUMER_GAS_LIMIT,
            "Must provide consumer enough gas"
        );
 
        (bool success, ) = callbackAddress.call(
            abi.encodeWithSelector(callbackFunctionId, requestId, data)
        ); // solhint-disable-line avoid-low-level-calls
        return success;
    }

    function fulfillOracleRequest2(
        bytes32 requestId,
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 expiration,
        bytes calldata data
    )
        external
        override
        validateAuthorizedSender
        validateRequestId(requestId)
        validateCallbackAddress(callbackAddress)
        validateMultiWordResponseId(requestId, data)
        returns (bool)
    {
        _verifyOracleRequestAndProcessPayment(
            requestId,
            payment,
            callbackAddress,
            callbackFunctionId,
            expiration,
            2
        );
        emit OracleResponse(requestId);
        require(
            gasleft() >= MINIMUM_CONSUMER_GAS_LIMIT,
            "Must provide consumer enough gas"
        );

        (bool success, ) = callbackAddress.call(
            abi.encodePacked(callbackFunctionId, data)
        ); // solhint-disable-line avoid-low-level-calls
        return success;
    }

    function transferOwnableContracts(
        address[] calldata ownable,
        address newOwner
    ) external onlyOwner {
        for (uint256 i = 0; i < ownable.length; i++) {
            s_owned[ownable[i]] = false;
            OwnableInterface(ownable[i]).transferOwnership(newOwner);
        }
    }

    function acceptOwnableContracts(
        address[] calldata ownable
    ) public validateAuthorizedSenderSetter {
        for (uint256 i = 0; i < ownable.length; i++) {
            s_owned[ownable[i]] = true;
            emit OwnableContractAccepted(ownable[i]);
            OwnableInterface(ownable[i]).acceptOwnership();
        }
    }

    function setAuthorizedSendersOn(
        address[] calldata targets,
        address[] calldata senders
    ) public validateAuthorizedSenderSetter {
        TargetsUpdatedAuthorizedSenders(targets, senders, msg.sender);

        for (uint256 i = 0; i < targets.length; i++) {
            AuthorizedReceiverInterface(targets[i]).setAuthorizedSenders(
                senders
            );
        }
    }

    function acceptAuthorizedReceivers(
        address[] calldata targets,
        address[] calldata senders
    ) external validateAuthorizedSenderSetter {
        acceptOwnableContracts(targets);
        setAuthorizedSendersOn(targets, senders);
    }

    function withdraw(
        address recipient,
        uint256 amount
    )
        external
        override(OracleInterface, WithdrawalInterface)
        onlyOwner
        validateAvailableFunds(amount)
    {
        assert(linkToken.transfer(recipient, amount));
    }

    function withdrawable()
        external
        view
        override(OracleInterface, WithdrawalInterface)
        returns (uint256)
    {
        return _fundsAvailable();
    }

    function ownerForward(
        address to,
        bytes calldata data
    ) external onlyOwner validateNotToLINK(to) {
        require(to.isContract(), "Must forward to a contract");
        (bool status, ) = to.call(data);
        require(status, "Forwarded call failed");
    }

    function ownerTransferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    )
        external
        override
        onlyOwner
        validateAvailableFunds(value)
        returns (bool success)
    {
        return linkToken.transferAndCall(to, value, data);
    }

    function distributeFunds(
        address payable[] calldata receivers,
        uint256[] calldata amounts
    ) external payable {
        require(
            receivers.length > 0 && receivers.length == amounts.length,
            "Invalid array length(s)"
        );
        uint256 valueRemaining = msg.value;
        for (uint256 i = 0; i < receivers.length; i++) {
            uint256 sendAmount = amounts[i];
            valueRemaining = valueRemaining.sub(sendAmount);
            receivers[i].transfer(sendAmount);
        }
        require(valueRemaining == 0, "Too much ETH sent");
    }

    function cancelOracleRequest(
        bytes32 requestId,
        uint256 payment,
        bytes4 callbackFunc,
        uint256 expiration
    ) external override {
        bytes31 paramsHash = _buildParamsHash(
            payment,
            msg.sender,
            callbackFunc,
            expiration
        );
        require(
            s_commitments[requestId].paramsHash == paramsHash,
            "Params do not match request ID"
        );
        // solhint-disable-next-line not-rely-on-time
        require(expiration <= block.timestamp, "Request is not expired");

        delete s_commitments[requestId];
        emit CancelOracleRequest(requestId);

        linkToken.transfer(msg.sender, payment);
    }

    function cancelOracleRequestByRequester(
        uint256 nonce,
        uint256 payment,
        bytes4 callbackFunc,
        uint256 expiration
    ) external {
        bytes32 requestId = keccak256(abi.encodePacked(msg.sender, nonce));
        bytes31 paramsHash = _buildParamsHash(
            payment,
            msg.sender,
            callbackFunc,
            expiration
        );
        require(
            s_commitments[requestId].paramsHash == paramsHash,
            "Params do not match request ID"
        );
        // solhint-disable-next-line not-rely-on-time
        require(expiration <= block.timestamp, "Request is not expired");

        delete s_commitments[requestId];
        emit CancelOracleRequest(requestId);

        linkToken.transfer(msg.sender, payment);
    }

    function getChainlinkToken() public view override returns (address) {
        return address(linkToken);
    }

    function _validateTokenTransferAction(
        bytes4 funcSelector,
        bytes memory data
    ) internal pure override {
        require(
            data.length >= MINIMUM_REQUEST_LENGTH,
            "Invalid request length"
        );
        require(
            funcSelector == OPERATOR_REQUEST_SELECTOR ||
                funcSelector == ORACLE_REQUEST_SELECTOR,
            "Must use whitelisted functions"
        );
    }

    function _verifyAndProcessOracleRequest(
        address sender,
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 nonce,
        uint256 dataVersion
    )
        private
        validateNotToLINK(callbackAddress)
        returns (bytes32 requestId, uint256 expiration)
    {
        requestId = keccak256(abi.encodePacked(sender, nonce));
        require(
            s_commitments[requestId].paramsHash == 0,
            "Must use a unique ID"
        );
        // solhint-disable-next-line not-rely-on-time
        expiration = block.timestamp.add(getExpiryTime);
        bytes31 paramsHash = _buildParamsHash(
            payment,
            callbackAddress,
            callbackFunctionId,
            expiration
        );
        s_commitments[requestId] = Commitment(
            paramsHash,
            _safeCastToUint8(dataVersion)
        );
        s_tokensInEscrow = s_tokensInEscrow.add(payment);
        return (requestId, expiration);
    }

    function _verifyOracleRequestAndProcessPayment(
        bytes32 requestId,
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 expiration,
        uint256 dataVersion
    ) internal {
        bytes31 paramsHash = _buildParamsHash(
            payment,
            callbackAddress,
            callbackFunctionId,
            expiration
        );
        require(
            s_commitments[requestId].paramsHash == paramsHash,
            "Params do not match request ID"
        );
        require(
            s_commitments[requestId].dataVersion <=
                _safeCastToUint8(dataVersion),
            "Data versions must match"
        );
        s_tokensInEscrow = s_tokensInEscrow.sub(payment);
        delete s_commitments[requestId];
    }

    function _buildParamsHash(
        uint256 payment,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 expiration
    ) internal pure returns (bytes31) {
        return
            bytes31(
                keccak256(
                    abi.encodePacked(
                        payment,
                        callbackAddress,
                        callbackFunctionId,
                        expiration
                    )
                )
            );
    }

    function _safeCastToUint8(uint256 number) internal pure returns (uint8) {
        require(number < MAXIMUM_DATA_VERSION, "number too big to cast");
        return uint8(number);
    }

    function _fundsAvailable() private view returns (uint256) {
        uint256 inEscrow = s_tokensInEscrow.sub(ONE_FOR_CONSISTENT_GAS_COST);
        return linkToken.balanceOf(address(this)).sub(inEscrow);
    }

    function _canSetAuthorizedSenders() internal view override returns (bool) {
        return isAuthorizedSender(msg.sender) || owner() == msg.sender;
    }

    modifier validateMultiWordResponseId(
        bytes32 requestId,
        bytes calldata data
    ) {
        require(data.length >= 32, "Response must be > 32 bytes");
        bytes32 firstDataWord;
        assembly {
            firstDataWord := calldataload(data.offset)
        }
        require(requestId == firstDataWord, "First word must be requestId");
        _;
    }

    modifier validateAvailableFunds(uint256 amount) {
        require(
            _fundsAvailable() >= amount,
            "Amount requested is greater than withdrawable balance"
        );
        _;
    }

    modifier validateRequestId(bytes32 requestId) {
        require(
            s_commitments[requestId].paramsHash != 0,
            "Must have a valid requestId"
        );
        _;
    }

    modifier validateNotToLINK(address to) {
        require(to != address(linkToken), "Cannot call to LINK");
        _;
    }

    modifier validateCallbackAddress(address callbackAddress) {
        require(!s_owned[callbackAddress], "Cannot call owned contract");
        _;
    }
}

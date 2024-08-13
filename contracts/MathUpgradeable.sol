// SPDX-License-Identifier: MIT

// MathUpgradeable.sol

pragma solidity ^0.8.4;

library MathUpgradeable {
    enum Rounding { Down, Up }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= type(uint256).max - a, "Math: addition overflow");
        return a + b;
    }
}

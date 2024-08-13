// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/DoubleEndedQueue.sol)
pragma solidity ^0.8.4;

library DoubleQueueModified {

    error Empty();

    error OutOfBounds();

    struct BytesDeque {
        int128 _begin;
        int128 _end;
        mapping(int128 => bytes) _data;
    }

    function pushBack(BytesDeque storage deque, bytes memory value) internal {
        int128 backIndex = deque._end;
        deque._data[backIndex] = value;
        unchecked {
            deque._end = backIndex + 1;
        }
    }

    function popFront(
        BytesDeque storage deque
    ) internal returns (bytes memory value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        value = deque._data[frontIndex];
        delete deque._data[frontIndex];
        unchecked {
            deque._begin = frontIndex + 1;
        }
    }

    function front(
        BytesDeque storage deque
    ) internal view returns (bytes memory value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        return deque._data[frontIndex];
    }

    function at(
        BytesDeque storage deque,
        uint256 index
    ) internal view returns (bytes memory value) {
        // int256(deque._begin) is a safe upcast
        int128 idx = _toInt128(int256(deque._begin) + _toInt256(index));
        if (idx >= deque._end) revert OutOfBounds();
        return deque._data[idx];
    }

    function _toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    function _toInt256(uint256 value) internal pure returns (int256) {
        require(
            value <= uint256(type(int256).max),
            "SafeCast: value doesn't fit in an int256"
        );
        return int256(value);
    }

    function clear(BytesDeque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    function length(BytesDeque storage deque) internal view returns (uint256) {

        unchecked {
            return uint256(int256(deque._end) - int256(deque._begin));
        }
    }

    function empty(BytesDeque storage deque) internal view returns (bool) {
        return deque._end <= deque._begin;
    }
}

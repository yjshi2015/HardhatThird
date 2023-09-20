// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Parent {
    uint public a;
    string public b;

    constructor(uint _a, string memory _b) {
        a = _a;
        b = _b;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Parent.sol";

contract Child is Parent {
    bool public c;
    uint public d;
    bytes public e;

    constructor(uint _a, string memory _b, bool _c, uint _d) Parent(_a, _b) {
        c = _c;
        d = _d;
        e = abi.encodePacked("syj nb");
    }
}
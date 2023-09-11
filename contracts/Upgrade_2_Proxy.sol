// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import "hardhat/console.sol";

/**
 * @title 该文件为代理模式，展示了Proxy的基本概念
 * 缺点：目标合约Target中的上下文是Proxy content
 * @author 
 * @notice 
 */
contract ContractDemo1 {
    
    uint public a;
    string public b;
    bool public c;

    function callMe(uint _a, string memory _b, bool _c) public {
        console.log("_a:",_a,", _b:",_b);
        console.log(" ,_c:", _c);
        a = _a + 1;
        b = string(abi.encodePacked("hello world! ", _b));
        c = !_c;
        console.log("a:", a, ", b:", b);
        console.log(", c:", c);
    }
}

contract ContractDemo2 {
    
    uint public a;
    string public b;
    bool public c;
    bytes public d;

    function callMe(uint _a, string memory _b, bool _c) public {
        console.log("_a:",_a,", _b:",_b);
        console.log(" ,_c:", _c);
        a = _a + 1;
        b = string(abi.encodePacked("hello world! ", _b));
        c = !_c;
        console.log("a:", a, ", b:", b);
        console.log(", c:", c);
    }
}

contract ProxyDemo {

    address public target;
    
    constructor(address _target) {
        target = _target;
    }

    function callTarget(uint256 gasLimit, bytes calldata _calldata) 
        public payable returns(bool)
    {
        (bool success,) = target.call{gas:gasLimit, value: msg.value}(_calldata);
        return success;
    }
}
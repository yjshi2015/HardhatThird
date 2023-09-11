// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract TargetContract {
    
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
//常规的delegatecall方式，即本身要保留状态变量
contract OrthodoxDelegateCaller {

    uint public a;
    string public b;
    bool public c;

    function callTarget(address _target, uint _a, string memory _b, bool _c) public returns(bool){
        (bool success,) = _target.delegatecall(abi.encodeWithSignature("callMe(uint256,string,bool)", _a, _b, _c));
        return success;
    }
}

//new way of delegatecall，不显式定义state variable，但是确实在该合约布局的对应槽位中，有相应的state variable
contract DelegateCaller2 {
        
    function callTarget(address _target, uint _a, string memory _b, bool _c) public {
        (bool success,) = _target.delegatecall(abi.encodeWithSignature("callMe(uint256,string,bool)", _a, _b, _c));
        require(success);
    }

    //查询0/1/2槽位，确实跟TargetContract布局对应
    function getValByPosition(uint256 _position) public view returns (bytes32 val) {
        assembly {
            val := sload(_position)
        }
    }
}

//代理模式，设置logic 合约槽位
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

import "hardhat/console.sol";
/**
 * @title 获取map结构中指定key的槽位
 * @author 
 * @notice 槽位计算逻辑：keccak256(h(k) . p)，其中h取决于key的类型，p为当前变量所在的槽位，
 *         p为小数点.为连接符，可使用abi.encode进行连接
 */
contract LayoutDemo {
    struct S { uint16 a; uint16 b; uint256 c; }
    uint public x;
    uint public y;
    uint public z;
    mapping (address => uint256) public account;
    mapping(uint => mapping(uint => S)) public data;

    constructor(uint _x, uint _y) {
        x = _x;
        y = _y;
        account[address(this)] = _x + 1;
        S memory s = S({
            a: uint16(x * 2),
            b: uint16(y * 3),
            c: x + y
        });
        data[x][y] = s;
    }

    function getValBySlot(uint256 _slot) public view returns(uint256 val) {
        assembly {
            val := sload(_slot)
        }
    }

    //获取account中指定key的槽位，按照keccak256(h(k) . p)的逻辑获取slot
    function getAccountMapSlot(address key) public pure returns (uint256 slot) {
        // keccak256(h(k) . p)
        slot = uint(keccak256(abi.encode(address(key), uint256(3))));
        console.log("slot: ", slot);
    }

    //mapping(uint => mapping(uint => S)) public data;
    //获取data[_x][_y].c的槽位，注意：c之前的2个状态变量被紧密打包在同一个slot
    function getDataMapSlot(uint _x, uint _y) public pure returns(uint slot) {
        uint firstKeySlot = uint256(keccak256(abi.encode(uint256(_x), uint256(4))));
        uint secondKeySlot = uint256(keccak256(abi.encode(uint256(_y), firstKeySlot)));
        //这里偏移量offset为1，而不是2
        slot = secondKeySlot + 1;
    }

    function getZSlot() public pure returns(uint256 z_slot) {
        assembly {
            z_slot := z.slot
        }
    }
}
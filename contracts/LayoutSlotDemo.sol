// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

import "hardhat/console.sol";
/**
 * @title 
 * @author 
 * @notice 
 * 获取map结构中指定key的槽位：
 *    获取槽位计算逻辑：keccak256(h(k) . p)，其中h取决于key的类型，p为当前变量所在的槽位，
 *    p为小数点.为连接符，可使用abi.encode进行连接
 * 
 * 获取动态数组中指定index元素的槽位：
 *    ①state variables的槽位记录了数组长度，在map中该slot的值为空
 *    ②获取index槽位计算逻辑：keccak256(p) + index
 */
contract LayoutDemo {
    struct S { uint16 a; uint16 b; uint256 c; }
    uint public x;
    uint public y;
    uint public z;
    mapping (address => uint256) public account;
    mapping(uint => mapping(uint => S)) public data;
    uint[] public dynamicArr;

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
        dynamicArr = new uint[](_x + _y);
    }

    //根据slot获取对应的值
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

    function putArr(uint _index, uint _x) external {
        uint len = dynamicArr.length;
        console.log("dynamicArr.length: ", len);
        dynamicArr[_index] = _x;
    }

    //对于dynamic array，它的state vairble所在的slot记录了数组长度
    function getArrLenBySlot() external view returns(uint len) {
        assembly {
            len := sload(5)
        }
    }

    
    //keccak256(p):该slot存储动态数组长度
    //keccak256(p) + index:为index元素的slot
    function getArrayItemSlot(uint _index) external pure returns (uint256 slot) {
        uint256 firstSlot = uint256(keccak256(abi.encode(5)));
        uint256 indexSlot = firstSlot + _index;
        slot = indexSlot;
    }
}
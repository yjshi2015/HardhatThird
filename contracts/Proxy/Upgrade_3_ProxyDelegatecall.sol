// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract LogicContract1 {
    
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

contract LogicContract2 {
    
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

/**
 * ①该proxy合约中state variable不需要显式声明，通过“delegatecall会自动”将logic合约的
 *  state variable自动映射到该合约中，并与其保持一致
 * ②logic合约的地址存通过inline assemble放在指定的slot中，而不是直接声明的方式（这种
 *  方式slot都是从0开始自增），是防止跟logic合约的槽位冲突；另外由于dynamic array和map
 *  的槽位也是keccak256计算来的，因为是logic proxy的slot是bytes32,所以与其冲突概率极低
 * ③logic合约升级时，如果增加state variable，必须采用append的方式，之前的state variable
 *  不允许修改，也不允许增删，否则会导致合约layout不一致
 * ④如果chain上部署，去掉console.sol
 */
contract UpgradeProxyDemo {

    //常量不占用布局
    bytes32 private constant targetPosition = keccak256("org.zeppelinos.proxy.target");
    bytes32 private constant ownerPosition = keccak256("org.zeppelinos.proxy.admin");


    constructor(address _target) {
        assembly {
            sstore(targetPosition, _target);
            sstore(ownerPosition, msg.sender);
        }
    }

    function setTarget(address _newTarget) public {
        //todo only owner
        assembly {
            sstore(targetPosition, _newTarget);
        }
    }

    function getTarget() public view returns (address target) {
        return sload(targetPosition);
    }

    fallback() external payable {
        // (bool success,) = getTarget().delegatecall{gas:gasLimit, value: msg.value}(msg.data);

        //跟上面注释掉的代码一样，都是delegatecall方式
        address impl = getTarget();
        require(impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
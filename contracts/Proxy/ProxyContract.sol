// SPDX-License-Identifier: MIT
// wtf.academy
pragma solidity ^0.8.4;

/**
 * @dev Proxy合约的所有调用都通过`delegatecall`操作码委托给另一个合约执行。后者被称为逻辑合约
 * （Implementation）。
 *
 * 委托调用的返回值，会直接返回给Proxy的调用者
 * 
 * Note： 
 * 1.如果单独调用Logic合约函数，它的state variabl按照logic自己的逻辑变化
 * 2.Proxy模式下，即使Logic合约的state variabl有值，并不会将“值”传递给Proxy合约，它的state variable的值依旧
 *   为该类型的默认值
 * 3.delegatecall使用内联汇编的目的，是为了让本来没有返回值的fallback回调函数有了返回值。通过caller合约的
 *   increase函数可以验证。
 * 4.当然，Proxy中如果直接定义一个新函数（比如：directDelegatecall），使用target.delegatecall()调用，也是能
 *   够得到返回值的，那为什么要使用fallback函数？
 *   因为fallback函数比重新定义一个函数实现起来更简洁，它能够让我们忘记Proxy合约，好像直接跟Logic合约交互一样。
 *   反之，如果重新定义一个新函数，每次都要调用该函数，但参数为abi.encodeWithSignature(Logic合约函数, arg);
 *   非常容易让人将Proxy、Logic合约混淆。
 * 验证方式：
 * 1.调用Logic合约increment函数，state variable变量x的值为100、101、102……
 * 2.调用Proxy合约通过Low level interactions，传递0xd09de08a函数，state variable
 * 变量x的值为1、2、3……，也可通过直接调用getValBySlot函数，获取slot为1的state variable的值
 */
contract Proxy {
    address public implementation; // 逻辑合约地址。implementation合约同一个位置的状态变量类型必须和Proxy合约的相同，不然会报错。

    /**
     * @dev 初始化逻辑合约地址
     */
    constructor(address implementation_){
        implementation = implementation_;
    }

    /**
     * @dev 回调函数，调用`_delegate()`函数将本合约的调用委托给 `implementation` 合约
     *      通过内联汇编，使得fallback回调函数有了返回值
     */
    fallback() external payable {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // 读取位置为0的storage，也就是implementation地址。
            let _implementation := sload(0)

            calldatacopy(0, 0, calldatasize())

            // 利用delegatecall调用implementation合约
            // delegatecall操作码的参数分别为：gas, 目标合约地址，input mem起始位置，input mem长度，output area mem起始位置，output area mem长度
            // output area起始位置和长度位置，所以设为0
            // delegatecall成功返回1，失败返回0
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // 将起始位置为0，长度为returndatasize()的returndata复制到mem位置0
            returndatacopy(0, 0, returndatasize())

            switch result
            // 如果delegate call失败，revert
            case 0 {
                revert(0, returndatasize())
            }
            // 如果delegate call成功，返回mem起始位置为0，长度为returndatasize()的数据（格式为bytes）
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}

    //验证直接delegatecall，是否能获取返回值
    //调用Logic合约的increment函数，预期的返回值是1
    function directDelegatecall(bytes calldata data) public returns(bytes memory) {
        (bool ok, bytes memory result) = implementation.delegatecall(data);
        require(ok, "delegatecall failed!");
        return result;
    }

    function getValBySlot(uint _slot) public view returns(uint256 val) {
        assembly {
            val := sload(_slot)
        }
    }
}

/**
 * @dev 逻辑合约，执行被委托的调用
 */
contract Logic {
    address public implementation; // 与Proxy保持一致，防止插槽冲突
    uint public x = 99; 
    event CallSuccess();

    // 这个函数会释放LogicCalled并返回一个uint。
    // 函数selector: 0xd09de08a
    function increment() external returns(uint) {
        emit CallSuccess();
        x++;
        return x;
    }

    function getStr(string calldata _str) public returns(string memory) {
        //todo 
    }
}

/**
 * @dev Caller合约，调用代理合约，并获取执行结果
 */
contract Caller{
    address public proxy; // 代理合约地址

    constructor(address proxy_){
        proxy = proxy_;
    }

    // 通过代理合约调用 increase()函数
    function increase() external returns(uint) {
        ( , bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        return abi.decode(data,(uint));
    }
}
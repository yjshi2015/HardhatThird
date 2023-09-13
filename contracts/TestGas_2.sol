/**
 * 通过transfer、send、call这3种方式进行转账，并对比gas数量
 * 每个函数都增加了payable修饰符，主要是为了支持转入ETH的同时转出
 *
 * Note:
 * 1、该模拟EOA账户转账，不用创建ERC20代币，将EOA账户的余额直接转到指定地址
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//接收者
contract ReceiveETH {

    event Log(uint256 _amount, uint256 _gasleft);

    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}

contract SendETH {
    
    constructor() payable {}

    receive() external payable {}

    //没有gas限制，最为灵活，是推荐的方式
    //gas:38605, transaction cost:33569, execution cost :11997
    function callTest(address recipent, uint amount) public returns (bool ok) {
        (ok,) = recipent.call{value: amount}("");
    }

    //交易失败自动revert，是次优选择
    //transfer的gas限制是2300，但实际在Remix中execution cost为11600，
    //GPT解释：2300是在EVM 0.6.0版本之前的限制，升级后transfer底层采用了call方式，支持更灵活的参数
    //设置，因此gas消耗就不再是固定值了。
    //不过ERC20中的transfer底层并没有使用call，而只是对状态变量balance进行了增减……
    //gas（数量单位）:38148, transaction cost（数量*价格）:33172, execution cost（数量）:11600
    function transferTest(address payable recipent, uint amount) public {
        recipent.transfer(amount);
    }

    //交易失败不会revert，弃用！！！
    //send的gas限制也是2300（这都过时的版本了吧），
    //有bool返回值,如果转账失败，不会回滚！！！
    //gas:38318, transaction cost :33320, execution cost : 11748
    function sendTest(address payable recipent, uint256 amount) public returns (bool ok) {
        ok = recipent.send(amount);
    }
    
}
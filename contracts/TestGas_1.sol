/**
 * 这个合约用来验证transfer和call转账时的gas区别
 * 结论：在Remix中执行，transfer的gas数量并不是2300，在metamask中转账，gas数量固定位21000
 * call的gas数量不确定，依赖于执行的函数操作
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";

import "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {}

    function mine(address miner, uint256 amount) public virtual {
        _mint(miner, amount);
    }
}

contract GasTest {

    MyToken myToken;
    
    constructor(address _myToken) {
        myToken = MyToken(_myToken);
    }

    receive() external payable {}

    //transfer的gas怎么不是2300
    function transferTest(address recipent, uint amount) public returns (bool ok){
        ok = myToken.transfer(recipent, amount);
    }

    function callTest(address recipent, uint amount) public returns (bytes memory) {
        (bool ok, bytes memory data) = recipent.call{value: amount}("");
        console.log("ok:", ok);
        return data;
    }
}
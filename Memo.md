#记录日常问题

## 今日问题

ctf-->mapping的布局
hardhat
nuiswap
前端react、uswagi

## 代办
solidity的layout storage ：https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html
memory layout 也了解下

5、当前项目是否有漏洞？？？
6、做赏金猎人

9、vscode快捷键 设置成跟IDEA一样

10、十六进制转化的网站是哪个？

11、再看upgradeContract

12、熟悉Solidity开发和优化，熟悉hardhat、Remix等开发工具、熟悉OpenZeppelin等三方安全合约库；

13、了解主流NFT或DeFi项目: opensea/rarible/foundation、aave/uniswap/synthetix等；

14、熟练使用hardhat/foundry等框架开发、测试、部署智能合约；

wtf课程



## ERC721
- safeTransferFrom：安全转账，究竟安全在哪里？
 - 如果接收方是合约地址，会要求实现ERC721Receiver接口
- 如果接收方为合约，但是没有实现IERC721Receiver(to).onERC721Received，为什么该NFT可能会进入黑洞地址？
done 无聊猿的地址是简单的拼接，并且可预测？？？     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
	3、如何debug？    可以点开右侧的Debug按钮，具体查看下面的logs。
done strings中的address转16进制函数，跟abi.encode结果应该是一样的，验证下！！！
	5、vscode无法打开import的sol文件
- 在Remix中发起写的交易时，需要小狐狸批准签名，但这个签名究竟在哪里用到了？
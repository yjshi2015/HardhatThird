# 记录日常问题

- 跨链桥
- rust
- hardhat
- nuiswap
- 前端react、uswagi

11、再看upgradeContract

12、熟悉Solidity开发和优化，熟悉hardhat、Remix等开发工具、熟悉OpenZeppelin等三方安全合约库；

13、了解主流NFT或DeFi项目: opensea/rarible/foundation、aave/uniswap/synthetix等；

14、熟练使用hardhat/foundry等框架开发、测试、部署智能合约；


- 已知合约地址和布局，能否获取私有state variable的值
 - 不行，但是可以得到state variable的slot。部署新合约，layout及state variabl的值跟原合约一模一样，进而按照规则计算相应的slot

- sol继承后，state variable如何定义！
 - child合约中直接定义新的state variable，不需要再重写一遍parent的state variable，否则继承有何意义？！

- ERC721中的safeTransferFrom：安全转账，究竟安全在哪里？
 - 如果接收方是合约地址，会要求实现ERC721Receiver接口

- 如果接收方为合约，但是没有实现IERC721Receiver(to).onERC721Received，为什么该NFT可能会进入黑洞地址？
 - 问题的关键不在于是否实现了onERC721Received接口，而是to合约中必须有相应的transfer操作，否则NFT无法转出，也即进入了黑洞地址

- 无聊猿的地址是简单的拼接，并且可预测？
 - 是的，简单拼接且可预测，baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 

- Strings中的address转16进制函数，跟abi.encode结果是否一样？
 - 一样的！本质上都是转成uint256数值，再把该数值转成16进制

- 在Remix中发起写的交易时，需要小狐狸批准签名，但这个签名究竟在哪里用到了？
 - 小狐狸签名后，该消息及上下文信息会被发布到区块链网络中，节点收到消息后进行验证，通过公钥msg.sender、签名signature以及消息体message，可以验证此次交易的数据是否被篡改，如果没有，则执行该笔交易。
# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
mkdir xxxfolder
cd xxxfolder
//安装hardhat
npm install --save-dev hardhat
//运行hardhat
npx hardhat
//安装依赖
npm install --save-dev @nomicfoundation/hardhat-toolbox
//编译solidity文件
npx hardhat compile
//运行测试用例
npx hardhat test [.\test\xxx.js]
//将合约部署到默认的hardhat测试网络上（本地内存中），命令行执行后数据就丢失，只能用来验证部署逻辑
npx hardhat run scripts/deploy.js
//将合约部署到sepolia测试网络上
npx hardhat run scripts/deploy.js --network sepolia

npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

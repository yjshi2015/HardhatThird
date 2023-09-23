const { ethers } = require("ethers");
const fs = require('fs')
const keyConfig = fs.readFileSync('../../scripts/keyConfig.json');
const keyConfigJson = JSON.parse(keyConfig);

// 初始化两条链的provider
const providerGoerli = new ethers.JsonRpcProvider(keyConfigJson.RPCProvider["goerli_testnet"]);
const providerSepolia = new ethers.JsonRpcProvider(keyConfigJson.RPCProvider["sepolia_testnet"]);


// 初始化两条链的signer
// privateKey填管理者钱包的私钥
const privateKey = keyConfigJson.account.privateKey;
const walletGoerli = new ethers.Wallet(privateKey, providerGoerli);
const walletSepolia = new ethers.Wallet(privateKey, providerSepolia);

// 合约地址和ABI
const contractAddressGoerli = "0x3a9165e34605A75C1fc3647Cc66c27463b04D3Ac";
const contractAddressSepolia = "0xD6F6EaD1Aa8Bf13FFe407485d8bCcE92A64717f3";

const abi = [
    "event Bridge(address indexed user, uint256 amount)",
    "function bridge(uint256 amount) public",
    "function mint(address to, uint amount) external",
];

// 初始化合约实例
const contractGoerli = new ethers.Contract(contractAddressGoerli, abi, walletGoerli);
const contractSepolia = new ethers.Contract(contractAddressSepolia, abi, walletSepolia);

const main = async () => {
    try{
        console.log(`开始监听跨链事件`)

        // 监听chain Sepolia的Bridge事件，然后在Goerli上执行mint操作，完成跨链
        contractSepolia.on("Bridge", async (user, amount) => {
            console.log(`Bridge event on Chain Sepolia: User ${user} burned ${amount} tokens`);

            // 在执行burn操作
            let tx = await contractGoerli.mint(user, amount);
            await tx.wait();

            console.log(`Minted ${amount} tokens to ${user} on Chain Goerli`);
        });

        // 监听chain Sepolia的Bridge事件，然后在Goerli上执行mint操作，完成跨链
        contractGoerli.on("Bridge", async (user, amount) => {
            console.log(`Bridge event on Chain Goerli: User ${user} burned ${amount} tokens`);

            // 在执行burn操作
            let tx = await contractSepolia.mint(user, amount);
            await tx.wait();

            console.log(`Minted ${amount} tokens to ${user} on Chain Sepolia`);
        });

    }catch(e){
        console.log(e);
    
    } 
}

main();

const { ethers } = require("ethers")
const fs = require('fs')
const keyConfig = fs.readFileSync('./keyConfig.json');
const keyConfigJson = JSON.parse(keyConfig);

const provider = new ethers.JsonRpcProvider('https://bscrpc.com')
const privateKey = keyConfigJson.account['privateKey'];
const wallet = new ethers.Wallet(privateKey, provider)



//生成签名信息
async function getSignature(_str) {
    // 等效于Solidity中的keccak256(abi.encodePacked(account, tokenId))
    const msgHash = ethers.solidityPackedKeccak256(
        ['string'],
        [_str])
    // console.log(`msgHash: ${msgHash}`);
    // 签名
    const messageHashBytes = ethers.getBytes(msgHash)
    const signature = await wallet.signMessage(messageHashBytes);
    console.log(`签名：${signature}`)
    return signature;
}


const main = async () => {
    getSignature('syjnb666');
    console.log(`--------------END--------------`)
}

main()
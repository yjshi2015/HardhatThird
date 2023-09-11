require("@nomicfoundation/hardhat-toolbox");
const {keyConfig} = require('./scripts/keyConfig.json');
// Go to https://alchemy.com, sign up, create a new App in
// its dashboard, and replace "KEY" with its key
const ALCHEMY_API_KEY = "2vsw2JgOi6Hq-";

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
// todo syj delete it after used
const SEPOLIA_PRIVATE_KEY = "";

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: keyConfig.RPCProvider["sepolia.testnet"],
      accounts: [SEPOLIA_PRIVATE_KEY]
    }
  }
};
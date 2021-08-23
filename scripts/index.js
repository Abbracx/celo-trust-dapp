// const Trust = artifacts.require('Trust');

const Trust = ('../build/contracts/Trust.json');

const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");

const { mnemonic, url, pri_key_1, pri_key_2 } = require('./config');
const token = 0x874069fa1eb16d44d622f2e0ca25eea172369bc;

// Or, alternatively pass in a zero-based address index.
// let provider = new HDWalletProvider({
//   mnemonic: mnemonic,
//   providerOrUrl: url,
//   addressIndex: 2,
// });

// const web3 = new Web3(provider);

// module.exports = async function(callback){

//   const trust = await Trust.deployed();
//   const accounts = await web3.eth.getAccounts();


//   let balance = await web3.eth.getBalance(accounts[0])

//   console.log(`#### cUsd balance of account[0] on Wallet ####`);
//   console.log(`Account balance is:  cUsd ${ web3.utils.fromWei(balance.toString()) }`);

//   let cBalance =  await web3.eth.getBalance(trust.address)


//   console.log(`#### cUsd balance of contract ####`);
//   console.log(`Trust contract balance is:  cUsd ${ web3.utils.fromWei(cBalance.toString()) }`);
//   callback();
// }

module.exports = async (callback) => {

  callback();
}

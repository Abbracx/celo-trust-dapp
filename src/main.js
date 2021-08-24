import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"

import trustContract from '../build/contracts/Trust.json'
import erc20Contract from "../build/contracts/IERC20Token.json"
const ERC20_DECIMALS = 18


let kit
let contract
let children = []
const TrustContractAddress = "0xA9A562f1B2DbfafAE436da4f2Da3E58188507887";

const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"


const connectCeloWallet = async function () {
  if (window.celo) {
    notification("⚠️ Please approve this Dapp to use wallet.")
    try {
      await window.celo.enable()
      notificationOff()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]

      contract = new kit.web3.eth.Contract(trustContract.abi, TrustContractAddress)

    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}


// Get MyCelo balance
const getBalance = async function () {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance;
  document.querySelector("#admin").textContent = kit.defaultAccount;
}

const getChildren = async function(){
  const _childrenLength = await contract.methods.getChildCount().call()
  const _children = []

  for(let j=0; j < _childrenLength; j++){
    let _child = new Promise( async (resolve, reject) => {
      let kid = await contract.methods.getKid(j).call()
      resolve({
        index: j,
        address: kid[0],
        name: kid[1],
        amount: new BigNumber(kid[2]),
        maturityTime: new Date(kid[3]),
        paid: kid[4],
      });
    });
    _children.push(_child)
  }
  children = await Promise.all(_children)
  renderKids()
}


async function approve(_price) {
  const cUSDContract = new kit.web3.eth.Contract(erc20Contract.abi, cUSDContractAddress)

  const result = await cUSDContract.methods
    .approve(TrustContractAddress, _price)
    .send({ from: kit.defaultAccount })
  return result
}


function renderKids() {
  document.getElementById("kidsList").innerHTML = ""
  children.forEach((_child) => {
    const newDiv = document.createElement("div")
    newDiv.className = "col-md-4"
    newDiv.innerHTML = childTemplate(_child)
    document.getElementById("kidsList").appendChild(newDiv)
  })
}

function childTemplate(_child) {
  return `
    <div class="card mb-4">
      <img class="card-img-top" src="${_child.image}" alt="...">
      <div class="position-absolute top-0 end-0 bg-warning mt-4 px-2 py-1 rounded-start">
        ${5} Sold
      </div>

      <div class="card-body text-left p-4 position-relative">
        <div class="translate-middle-y position-absolute top-0">
        ${identiconTemplate(_child.address)}
        </div>
        <h2 class="card-title fs-4 fw-bold mt-2">${_child.name}</h2>


        <p class="card-text mt-4">
          <i class="bi bi-geo-alt-fill"></i>
          <span>${_child.maturityTime.toUTCString()}</span>
        </p>
        <div class="d-grid gap-2">
          <a class="btn btn-lg btn-outline-dark buyBtn fs-6 p-3" id=${
            _child.index
          }>
            Your Deposited money is ${_child.amount.shiftedBy(-ERC20_DECIMALS).toFixed(2)} cUSD
          </a>
        </div>
      </div>
    </div>
  `
}

function identiconTemplate(_address) {
  const icon = blockies
    .create({
      seed: _address,
      size: 8,
      scale: 16,
    })
    .toDataURL()

  return `
  <div class="rounded-circle overflow-hidden d-inline-block border border-white border-2 shadow-sm m-0">
    <a href="https://alfajores-blockscout.celo-testnet.org/address/${_address}/transactions"
        target="_blank">
        <img src="${icon}" width="48" alt="${_address}">
    </a>
  </div>
  `
}

function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}

window.addEventListener('load', async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  await getChildren()
  notificationOff()
});


document.querySelector("#newChildBtn").addEventListener("click", async (e) => {
    const params = [
      document.getElementById("childAddress").value,
      document.getElementById("childName").value,
      new BigNumber(document.getElementById("amount").value)
      .shiftedBy(ERC20_DECIMALS)
      .toString(),
      document.getElementById("maturityTime").value,
    ]
    notification(`⌛ Adding "${params[1]}"...`)

    try {
      notification("⌛ Waiting for deposit approval...");

      await approve(document.getElementById("amount").value);

      const result = await contract.methods
        .addKid(...params)
        .send({ from: kit.defaultAccount })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 You successfully added "${params[1]}" and deposited "${params[2]}".`);
    getChildren();
  });


//   document.querySelector("#marketplace").addEventListener("click", async (e) => {
//     if(e.target.className.includes("buyBtn")) {
//       const index = e.target.id
//       notification("⌛ Waiting for deposit approval...")

//       // make approval for payment
//       try {
//         await approve(children[index].amount)
//       } catch (error) {
//         notification(`⚠️ ${error}.`)
//       }

//       notification(`⌛ Awaiting deposit for "${children[index].name}"...`)

//       //make the payment after the approval above.
//       try {
//         const result = await contract.methods
//           .buyProduct(index)
//           .send({ from: kit.defaultAccount })
//         notification(`🎉 You successfully bought "${products[index].name}".`)
//         getProducts()
//         getBalance()
//       } catch (error) {
//         notification(`⚠️ ${error}.`)
//       }
//     }
// });


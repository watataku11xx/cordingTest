const fs = require('fs');
const testNFT = artifacts.require("testNFT");

module.exports = async function(deployer) {

  // 設問1
  const nftInstance = await testNFT.deployed();

  // 設問2
  let token_ids = new Array();
  let ipfs = new Array();

  const data = fs.readFileSync('./data.json');
  const jsonData = JSON.parse(data);
  for (let i = 0; i < jsonData.length; i++) {
    token_ids.push(jsonData[i].token_id);
    ipfs.push(jsonData[i].ipfs);
  }


  // 設問3
  const name = "testNFT";
  const symbol = "testNFT";
  const tokenIndex = 0;
  const mintingTime = new Date(new Date('2023-04-03T13:00:00').getTime() + (3 * 60 * 60 * 1000));
  const paymentCurrencyAddress = "0xc5b4496C59818C34ff65d32b11824E4d425aDDb2";
  const paymentAddress = "0xaeA01321CEB7Ef7624b0f78b36716619f9c78d79";

  await deployer.deploy(name, symbol, tokenIndex, mintingTime, paymentCurrencyAddress,token_ids, ipfs, paymentAddress);
};
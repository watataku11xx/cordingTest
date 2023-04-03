const { ethers, artifacts } = require("hardhat");
const fs = require('fs');

async function main() {
    const MyContract = await ethers.getContractFactory("testNFT");
    
    let token_ids = new Array();
    let ipfs = new Array();
    
    try{
        const data = fs.readFileSync('./data.json');
        const jsonData = JSON.parse(data);
        for (let i = 0; i < jsonData.length; i++) {
                token_ids.push(jsonData[i].token_id);
                ipfs.push(jsonData[i].ipfs);
        }
    } catch (err){
        console.log(err)
    }   

    const name = "testNFT";
    const symbol = "testNFT";
    const tokenIndex = 0;
    const mintingTime = new Date(new Date('2023-04-03T13:00:00').getTime() + (3 * 60 * 60 * 1000));
    const paymentCurrencyAddress = "0xc5b4496C59818C34ff65d32b11824E4d425aDDb2";
    const paymentAddress = "0xaeA01321CEB7Ef7624b0f78b36716619f9c78d79";
    
    const myContract = await MyContract.deploy(name, symbol, tokenIndex, mintingTime, paymentCurrencyAddress,token_ids, ipfs, paymentAddress);
    await myContract.deployed();

    console.log("MyContract deployed to:", myContract.address);

    const artifact = artifacts.readArtifact("testNFT");
    console.log(artifact);
}

main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
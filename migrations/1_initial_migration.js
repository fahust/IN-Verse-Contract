const AuctionContract = artifacts.require("AuctionContract");
const INERC721A = artifacts.require("INERC721A");

module.exports = async function (deployer) {
  
  await deployer.deploy(INERC721A,"test","TST","uri");
  let INERC721AInstance = await INERC721A.deployed();
  
  await deployer.deploy(AuctionContract);
  let AuctionContractInstance = await AuctionContract.deployed();
  
};

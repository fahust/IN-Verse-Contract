const AdminController = artifacts.require("AdminController");
const AuctionContract = artifacts.require("AuctionContract");
const TokenContract = artifacts.require("TokenContract");

module.exports = async function (deployer) {
  //await deployer.deploy(AdminController);
  //let AdminControllerInstance = await AdminController.deployed();
  
  await deployer.deploy(TokenContract,"test","TST","uri",1);
  let TokenContractInstance = await TokenContract.deployed();
  
  await deployer.deploy(AuctionContract,TokenContractInstance.address);
  let AuctionContractInstance = await AuctionContract.deployed();
  
};

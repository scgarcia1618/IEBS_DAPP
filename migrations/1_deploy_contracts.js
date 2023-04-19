var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var Auction = artifacts.require("./Auction.sol");
var Marketplace = artifacts.require("./Marketplace.sol");


module.exports = function(deployer) {
  deployer.deploy(Marketplace);
};

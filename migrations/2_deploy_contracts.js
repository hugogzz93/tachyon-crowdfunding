var Crowdfund = artifacts.require("./Crowdfund.sol");

module.exports = function(deployer) {
  console.log(deployer);
  deployer.deploy(Crowdfund, 10, 10);
};

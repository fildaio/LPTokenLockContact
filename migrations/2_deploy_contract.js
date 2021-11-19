const LockToken = artifacts.require("LockToken");

module.exports = function (deployer) {
  deployer.deploy(LockToken, 1668823200);
  //deployer.deploy(LockToken, 1637298000);
};

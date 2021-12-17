const LockToken = artifacts.require("LockToken");
const LockLP = artifacts.require("LockLP");

module.exports = function (deployer) {
  deployer.deploy(LockToken, 1668823200);

  await deployer.deploy(LockLP,
    LockToken.address,
    '0xE36FFD17B2661EB57144cEaEf942D95295E637F0', // token0
    '0x0298c2b32eae4da002a15f36fdf7615bea3da047', // token1
    '0xED7d5F38C79115ca12fe6C0041abb22F0A06C300'  // router
    );
};

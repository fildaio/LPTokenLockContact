const LockToken = artifacts.require("LockToken");
const LockLP = artifacts.require("LockLP");
const LockETHLP = artifacts.require("LockETHLP");

module.exports = async function (deployer, network, accounts) {
  if (network == 'heco') {
    await deployer.deploy(LockToken, 1668823200);

    await deployer.deploy(LockLP,
      LockToken.address,
      '0xE36FFD17B2661EB57144cEaEf942D95295E637F0', // token0
      '0x0298c2b32eae4da002a15f36fdf7615bea3da047', // token1
      '0xED7d5F38C79115ca12fe6C0041abb22F0A06C300'  // router
      );
  } else if (network == 'esc') {
    await deployer.deploy(LockToken, 1679554835);

    await deployer.deploy(LockETHLP,
      LockToken.address,
      '0x00E71352c91Ff5B820ab4dF08bb47653Db4e32C0', // token
      '0x517E9e5d46C1EA8aB6f78677d6114Ef47F71f6c4', // WELA
      '0xec2f2b94465Ee0a7436beB4E38FC8Cf631ECf7DF'  // router
      );
  }


};

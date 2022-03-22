const LockToken = artifacts.require("LockToken");
const LockLP = artifacts.require("LockLP");

module.exports = async function (deployer, network, accounts) {


  if (network == 'heco') {
    await deployer.deploy(LockLP,
      '0xa262C4fCEf3Be488A1Dc2bD6B6F61B1a2CE00Ba2',
      '0xE36FFD17B2661EB57144cEaEf942D95295E637F0', // token0
      '0x0298c2b32eae4da002a15f36fdf7615bea3da047', // token1
      '0xED7d5F38C79115ca12fe6C0041abb22F0A06C300'  // router
      );
  } else if (network == 'iotex') {
    await deployer.deploy(LockToken, 1640871400);
    await deployer.deploy(LockLP,
      LockToken.address,
      '0x32085B8ea854529178bD0F4E92D3fd2475A3A159', // token0
      '0x84abcb2832be606341a50128aeb1db43aa017449', // token1
      '0x95cb18889b968ababb9104f30af5b310bd007fd8'  // router
      );
  }

};

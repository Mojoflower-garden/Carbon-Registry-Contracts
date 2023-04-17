// migrations/NN_deploy_upgradeable_box.js
const { deployBeacon, deployProxy, deployBeaconProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const TokenVault = artifacts.require('TokenVault');
const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');
// const ProjectSmol = artifacts.require('ProjectSmol');

module.exports = async function (deployer) {

  // const d = await deployer.deploy(Project)

  // const beacon = await deployBeacon(Test);
  // console.log('Beacon deployed', beacon.address);

  const existingRegistry = await CarbonContractRegistry.deployed();
  console.log('CarbonContractRegistry deployed', existingRegistry.address);

  
  const beacon = await deployBeacon(TokenVault);
  console.log('Beacon deployed', beacon.address);

  const instance = await upgradeProxy(existingRegistry.address, CarbonContractRegistry, { deployer, unsafeSkipStorageCheck: true });
  console.log("Upgraded", instance.address);

  await instance.setTokenVaultBeaconAddress(beacon.address);
  console.log("SET BEACON ADDRESS", beacon.address);
  await existingRegistry.createNewVerifiedVault();
  console.log("CREATED NEW VERIFIED VAULT")



  // Just for docs...
  const beaconProxy = await deployBeaconProxy(beacon, TokenVault, [ existingRegistry.address])
    console.log("Beacon Proxy deployed", beaconProxy.address)

};
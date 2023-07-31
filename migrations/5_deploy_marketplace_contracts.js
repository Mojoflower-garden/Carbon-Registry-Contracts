// migrations/NN_deploy_upgradeable_box.js
const { deployBeacon, deployProxy, deployBeaconProxy } = require('@openzeppelin/truffle-upgrades');

const MarketplaceVault = artifacts.require('MarketplaceVault');
const MarketplaceFactory = artifacts.require('MarketplaceFactory');
// const ProjectSmol = artifacts.require('ProjectSmol');

module.exports = async function (deployer) {
  
  const beacon = await deployBeacon(MarketplaceVault);
  console.log('Beacon deployed', beacon.address);

  const registry = await deployProxy(MarketplaceFactory, [beacon.address], { deployer, kind: 'uups' });
  console.log('MarketplaceFactory deployed', registry.address);


  // Just to get the artifact generated
  const beaconProxy = await deployBeaconProxy(beacon, MarketplaceVault, [
    "0x333D9A49b6418e5dC188989614f07c89d8389CC8",
    "Generic Marketplace Contract"])
    console.log("Beacon Proxy deployed", beaconProxy.address)
};
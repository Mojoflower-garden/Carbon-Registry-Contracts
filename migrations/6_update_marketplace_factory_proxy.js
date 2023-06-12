// migrations/NN_deploy_upgradeable_box.js
const { upgradeBeacon, erc1967, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const MarketplaceFactory = artifacts.require('MarketplaceFactory');

module.exports = async function (deployer) {
  // const project = await ProjectBeacon.deployed();
  // console.log("Project address", project.address);
  // const addressOfLiveBeaconProxy = "0x1912b30f7a10a07e18bc9ce831a56b8a07d0d6ac" // Polygon mumbai
  // const addressOfLiveBeaconProxy = "0x9587baE77c5CEde9CAB1a29eEDb4D55f58529163" // arbitrum
  // const addressOfProxy = "0x32312b22883283cF33441001ee73EA217a771a20" // polygon
  // const beaconAddress = await erc1967.getBeaconAddress(addressOfLiveBeaconProxy);
  // console.log("Beacon address", beaconAddress);
  // await upgradeProxy(beaconAddress, MarketplaceFactory, { deployer, unsafeSkipStorageCheck: true });
  // console.log("Beacon upgraded", beaconAddress);
  const existing = await MarketplaceFactory.deployed();
  const instance = await upgradeProxy(existing.address, MarketplaceFactory, { deployer, unsafeSkipStorageCheck: true });
  console.log("Upgraded proxy instance", instance.address)
};
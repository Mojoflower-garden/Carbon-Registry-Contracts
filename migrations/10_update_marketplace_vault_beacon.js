// migrations/NN_deploy_upgradeable_box.js
const { upgradeBeacon, erc1967 } = require('@openzeppelin/truffle-upgrades');

const MarketplaceVault = artifacts.require('MarketplaceVault');

module.exports = async function (deployer) {
  console.log("ONly for updating the marketplace vault beacon")
  return
  // const project = await ProjectBeacon.deployed();
  // console.log("Project address", project.address);
  const addressOfLiveBeaconProxy = "0x730CaaE527486ad83B56f5C59B1A2D519Ea65d38" // Polygon mumbai
  // const addressOfLiveBeaconProxy = "0x9587baE77c5CEde9CAB1a29eEDb4D55f58529163" // arbitrum
  // const addressOfLiveBeaconProxy = "0xCe08a19a00a24F0937A63A0a8FaC3169457C085F" // polygon
  // const marketplace = await MarketplaceVault.deployed();
  // const beaconAddress = await erc1967.getBeaconAddress(addressOfLiveBeaconProxy);
  // console.log("Beacon address", beaconAddress);
  await upgradeBeacon(addressOfLiveBeaconProxy, MarketplaceVault, { deployer, unsafeSkipStorageCheck: true });
  console.log("Beacon upgraded", addressOfLiveBeaconProxy);
};
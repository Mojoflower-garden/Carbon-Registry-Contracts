// migrations/NN_deploy_upgradeable_box.js
const { upgradeBeacon, erc1967 } = require('@openzeppelin/truffle-upgrades');

const ProjectBeacon = artifacts.require('Project');

module.exports = async function (deployer) {
  // const project = await ProjectBeacon.deployed();
  // console.log("Project address", project.address);
  const addressOfLiveBeaconProxy = "0x1912b30f7a10a07e18bc9ce831a56b8a07d0d6ac"
  const beaconAddress = await erc1967.getBeaconAddress(addressOfLiveBeaconProxy);
  console.log("Beacon address", beaconAddress);
  await upgradeBeacon(beaconAddress, ProjectBeacon, { deployer, unsafeSkipStorageCheck: true });
  console.log("Beacon upgraded", beaconAddress);

};
// migrations/NN_deploy_upgradeable_box.js
const { upgradeBeacon, erc1967 } = require('@openzeppelin/truffle-upgrades');

const ProjectBeacon = artifacts.require('Project');

module.exports = async function (deployer) {

    const existing = await ProjectBeacon.deployed();

  const beaconAddress = await erc1967.getBeaconAddress(existing.address);
  console.log("Beacon address", beaconAddress);
  await upgradeBeacon(beaconAddress, ProjectBeacon, { deployer });
  console.log("Beacon upgraded", beaconAddress);

  const instance = await ProjectBeacon.at(existing.address);
console.log("Instance upgraded", instance.address);
};
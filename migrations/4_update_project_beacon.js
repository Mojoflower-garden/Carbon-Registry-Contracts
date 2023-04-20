// migrations/NN_deploy_upgradeable_box.js
const { upgradeBeacon, erc1967 } = require('@openzeppelin/truffle-upgrades');

const ProjectBeacon = artifacts.require('Project');

module.exports = async function (deployer) {
  const project = await ProjectBeacon.deployed();
  console.log("Project address", project.address);
  const beaconAddress = await erc1967.getBeaconAddress(project.address);
  console.log("Beacon address", beaconAddress);
  await upgradeBeacon(beaconAddress, ProjectBeacon, { deployer });
  console.log("Beacon upgraded", beaconAddress);

  const instance = await ProjectBeacon.at(project.address);
};
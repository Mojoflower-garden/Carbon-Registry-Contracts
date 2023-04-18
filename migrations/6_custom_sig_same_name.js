// migrations/NN_deploy_upgradeable_box.js
const { upgradeBeacon, erc1967 } = require('@openzeppelin/truffle-upgrades');

const ProjectBeacon = artifacts.require('Project');

module.exports = async function (deployer) {

  //   const existing = await ProjectBeacon.deployed();

  //   console.log("Existing address", existing.address)
  // const beaconAddress = await erc1967.getBeaconAddress(existing.address);
  const beaconAddress = "0xF4425928Cd329a599d5DDd48D94c793014337726"
  console.log("Beacon address", beaconAddress);
  await upgradeBeacon(beaconAddress, ProjectBeacon, { deployer });
  console.log("Beacon upgraded", beaconAddress);

  const instance = await ProjectBeacon.at(existing.address);
console.log("Instance upgraded", instance.address);
};
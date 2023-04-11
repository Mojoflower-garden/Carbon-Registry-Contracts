// migrations/NN_deploy_upgradeable_box.js
const { deployBeacon } = require('@openzeppelin/truffle-upgrades');

const Project = artifacts.require('Project');
const ProjectFactory = artifacts.require('ProjectFactory');

// const MyToken = artifacts.require("MyToken");

module.exports = async function (deployer) {
  
  const beacon = await deployBeacon(Project);
  console.log('Beacon deployed', beacon.address);

  const result = await deployer.deploy(ProjectFactory, beacon.address);
  console.log("ProjectFactory deployed", result.address);
};
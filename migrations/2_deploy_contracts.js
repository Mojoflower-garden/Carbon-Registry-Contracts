// migrations/NN_deploy_upgradeable_box.js
const { deployBeacon, deployProxy } = require('@openzeppelin/truffle-upgrades');

const Project = artifacts.require('Project');
const ProjectFactory = artifacts.require('ProjectFactory');
const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');

module.exports = async function (deployer) {
  
  const beacon = await deployBeacon(Project);
  console.log('Beacon deployed', beacon.address);

  const registry = await deployProxy(CarbonContractRegistry, [beacon.address], { deployer, kind: 'uups' });
  console.log('CarbonContractRegistry deployed', registry.address);

  const projectFactory = await deployer.deploy(ProjectFactory, registry.address);
  console.log("ProjectFactory deployed", result.address);

  await registry.setProjectFactoryAddress(projectFactory.address);
};
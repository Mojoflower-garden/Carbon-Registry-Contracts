// migrations/NN_deploy_upgradeable_box.js
const { deployBeacon, deployProxy } = require('@openzeppelin/truffle-upgrades');

const Project = artifacts.require('Project');
const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');

module.exports = async function (deployer) {
  
  const beacon = await deployBeacon(Project);
  console.log('Beacon deployed', beacon.address);

  const registry = await deployProxy(CarbonContractRegistry, [beacon.address], { deployer, kind: 'uups' });
  console.log('CarbonContractRegistry deployed', registry.address);
};
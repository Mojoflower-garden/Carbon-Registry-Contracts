// migrations/NN_deploy_upgradeable_box.js
const { deployBeacon, deployProxy, deployBeaconProxy } = require('@openzeppelin/truffle-upgrades');

const Project = artifacts.require('Project');
const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');
// const ProjectSmol = artifacts.require('ProjectSmol');

module.exports = async function (deployer) {

  // const d = await deployer.deploy(Project)

  // const beacon = await deployBeacon(Test);
  // console.log('Beacon deployed', beacon.address);
  
  const beacon = await deployBeacon(Project);
  console.log('Beacon deployed', beacon.address);

  const registry = await deployProxy(CarbonContractRegistry, [beacon.address], { deployer, kind: 'uups' });
  console.log('CarbonContractRegistry deployed', registry.address);

  const beaconProxy = await deployBeaconProxy(beacon, Project, [ registry.address,
    "0xE1E8d68de7eDBeB4f02710C3a7D3D24D0D42493d",
    0,
    "Test Beacon"])
    console.log("Beacon Proxy deployed", beaconProxy.address)


};
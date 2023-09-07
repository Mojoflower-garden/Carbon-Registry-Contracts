// migrations/NN_deploy_upgradeable_box.js
const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');

module.exports = async function (deployer) {
  // const project = await ProjectBeacon.deployed();
  // console.log("Project address", project.address);
  // const addressOfLiveBeaconProxy = "0x1912b30f7a10a07e18bc9ce831a56b8a07d0d6ac" // Polygon mumbai
  // const addressOfLiveBeaconProxy = "0x9587baE77c5CEde9CAB1a29eEDb4D55f58529163" // arbitrum
  const carbonContractRegAddress =  "0x9f87988FF45E9b58ae30fA1685088460125a7d8A" //"0xCe08a19a00a24F0937A63A0a8FaC3169457C085F" // polygon
  // const carbonContractRegAddress = "0x825CcCB05D82fcD0381E523116A03b9301E91C61" // Mumbai
  console.log("CarbonContractRegAddress", carbonContractRegAddress);
  const instance = await upgradeProxy(carbonContractRegAddress, CarbonContractRegistry, { deployer });
  console.log("Upgraded", instance.address);
};
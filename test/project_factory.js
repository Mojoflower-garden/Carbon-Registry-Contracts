const { deployBeacon, deployBeaconProxy, upgradeBeacon } = require('@openzeppelin/truffle-upgrades');

const ProjectFactory = artifacts.require("ProjectFactory");
const Project = artifacts.require('Project');
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ProjectFactory", function (/* accounts */) {

  let factory = null;
  let beacon = null;
  before(async function () {
    // beacon = await deployBeacon(Project);
    // console.log("Beacon deployed", beacon.address)
    factory = await ProjectFactory.deployed();
  })
  it("should assert true", async function () {
    console.log('Factory points to', await factory.getBeacon());
    await factory.createProject();
    return assert.isTrue(true);
  });
});

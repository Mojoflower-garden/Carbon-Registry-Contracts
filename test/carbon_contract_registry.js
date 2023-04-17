const { deployBeacon, deployBeaconProxy,deployProxy, upgradeBeacon } = require('@openzeppelin/truffle-upgrades');

const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');
const Project = artifacts.require('Project');
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CarbonContractRegistry", function (accounts) {

  let registry = null;
  let beacon = null;
  before(async function () {
    beacon = await deployBeacon(Project);  
    registry = await deployProxy(CarbonContractRegistry, [beacon.address], {  kind: 'uups' });
  })

  it("should have same beacon address", async function () {
    assert(beacon.address === await registry.getBeaconAddress(), "Beacon address should be the same");
  });
  
  it("should create project and save id and address pointers", async function () {
    // console.log('Factory points to', await registry.getBeacon());
    const projectId = 1;
    const projectName = "Test Project"
    const result = await registry.createProject(projectId, projectName);

    const createProjectLog = result.logs.find(l => l.event === 'ProjectCreated');
    const idSaved = createProjectLog.args.projectId.toNumber();
    const addressSaved = createProjectLog.args.projectAddress;
    const projectNameSaved = createProjectLog.args.projectName; 
    const projectAddress = await registry.getProjectAddressFromId(1);

    assert(idSaved === projectId, `Saved id ${idSaved} should be equal to ${projectId}`);
    assert(projectNameSaved === projectName, `Saved name ${projectNameSaved} should be equal to ${projectName}`);
    assert(addressSaved === projectAddress, `Saved address ${addressSaved} should be equal to ${projectAddress}`);
  });

  it("should not create project with same Id as another project", async function () {
    // console.log('Factory points to', await registry.getBeacon());
    const projectId = 2;
    const projectName = "Test Project"
    await registry.createProject(projectId, projectName);
    let failed = true;
    try {
      await registry.createProject(projectId, projectName);
      failed = false;
    } catch (error) {}
    assert(failed, "Should not be able to create project with same id as another project");
  });

  it("should not create project with Id = 0", async function () {
    // console.log('Factory points to', await registry.getBeacon());
    const projectId = 0;
    const projectName = "Test Project"
    let failed = true;
    try {
      await registry.createProject(projectId, projectName);
      failed = false;
    } catch (error) {}
    assert(failed, "Should not be able to create project with id = 0");
  });


  it("should set verified vault address", async function () {
    // Arrange
    const verifiedVaultAddress = web3.utils.toChecksumAddress('0x1234567890123456789012345678901234567890');

    // Act
    await registry.setVerifiedVaultAddress(verifiedVaultAddress);

    // Assert
    const result = await registry.getVerifiedVaultAddress();
    assert.equal(result, verifiedVaultAddress, "The verified vault address should be set correctly");
  });

  it("should register serialization and verify msg.sender as the address of the serialization", async function () {
    // Arrange
    const serialization = "TestSerialization";

    // Act
    await registry.registerSerialization(serialization);

    // Assert
    const result = await registry.getSerializationAddress(serialization);
    assert.equal(accounts[0], result, "The serialization address should be set correctly");
  });

  it("should update beacon address", async function () {
    // Arrange
    const newBeaconAddress = web3.utils.toChecksumAddress('0x1234567890123456789012345678901234567890');

    // Act
    await registry.setBeaconAddress(newBeaconAddress);

    // Assert
    const result = await registry.getBeaconAddress();
    assert.equal(result, newBeaconAddress, "The project beacon address should be updated correctly");
  });

});

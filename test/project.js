const { deployBeacon, deployBeaconProxy,deployProxy, upgradeBeacon } = require('@openzeppelin/truffle-upgrades');
const CarbonContractRegistry = artifacts.require('CarbonContractRegistry');
const Project = artifacts.require("Project");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Project", function (accounts) {
  const projectId = 1;
  const projectName = "Test Project"
  let beacon = null;
  let projectProxy = null;
  let registry = null;
  before(async function () {
    beacon = await deployBeacon(Project);  
    registry = await deployProxy(CarbonContractRegistry, [beacon.address], {  kind: 'uups' });
    const result = await registry.createProject(projectId, projectName);
    const createProjectLog = result.logs.find(l => l.event === 'ProjectCreated');
    const addressSaved = createProjectLog.args.projectAddress;
    projectProxy = await Project.at(addressSaved)
  })
  it("should assert correct initial data", async function () {
    const savedProjectId = await projectProxy.projectId();
    const savedProjectName = await projectProxy.projectName();
    const savedContractRegistry = await projectProxy.contractRegistry();

    assert.equal(savedProjectId.toNumber(), projectId, `Saved id ${savedProjectId} should be equal to ${projectId}`);
    assert.equal(savedProjectName, projectName, `Saved name ${savedProjectName} should be equal to ${projectName}`);
    assert.equal(savedContractRegistry, registry.address, `Saved address ${savedContractRegistry} should be equal to ${registry.address}`);
  });

  it("should create vintage", async function () {
    const {
      exPostId,
      serialization,
      estAmount
    } = await createBasicExPostVintage();

    const exPostVintageData = await projectProxy.exPostVintageMapping(exPostId);
    assert.equal(exPostVintageData.estMitigations.toNumber(), estAmount, `Saved estimated amount ${exPostVintageData.estMitigations} should be equal to ${estAmount}`);
    assert.equal(exPostVintageData.serialization, serialization, `Saved serialization ${exPostVintageData.serialization} should be equal to ${serialization}`);
    assert(!exPostVintageData.verified, `Saved verified ${exPostVintageData.verified} should be false`);

    const tokenIdFromSer = await projectProxy.serializationToExPostTokenIdMapping(serialization)
    assert.equal(tokenIdFromSer.toNumber(), exPostId, `Saved token id ${tokenIdFromSer} should be equal to ${exPostId}`);

    const serializationAddress = await registry.getSerializationAddress(serialization);
    assert.equal(serializationAddress, projectProxy.address, `Saved serialization address ${serializationAddress} should be equal to ${projectProxy.address}`);
  })

  it("should not create vintage with serialization that already exists", async function () {
    const serialization = "ICR-ISL-2020-01-01-2020-12-31-1-2023-new-vintage"
    await createBasicExPostVintage({
      serialization
    });
    const failed = true
    try {
      await createBasicExPostVintage({
        serialization
      });      
      failed = false
    }catch (e) {
    }
    assert(failed, `Should have failed to create vintage with serialization ${serialization} that already exists`);
  });

  it("should create exAnte for vintage", async function () {
    const anteAmount = 5000;
    const {
      exPostId
    } = await createBasicExPostVintage();
    const anteResult = await projectProxy.mintExAnte(accounts[1], exPostId, anteAmount,  web3.utils.fromAscii(""));
    const exAnteMintedLog = anteResult.logs.find(l => l.event === 'ExAnteMinted');
    const exAnteId = exAnteMintedLog.args.tokenId.toNumber();

    const exPostIdFromAnte = await projectProxy.exAnteToExPostTokenId(exAnteId)
    assert.equal(exPostIdFromAnte.toNumber(), exPostId, `Saved ex post id ${exPostIdFromAnte} should be equal to ${exPostId}`);

    const balanceOfReceiveAccount = await projectProxy.balanceOf(accounts[1], exAnteId);
    assert.equal(balanceOfReceiveAccount.toNumber(), anteAmount, `Saved balance of receive account ${balanceOfReceiveAccount} should be equal to ${anteAmount}`);
  });

  it("should not create more exAnte than maxAntePercentage of estimated vintages allows, default is 50%", async function () {
    const anteAmount = 5000;
    const {
      exPostId
    } = await createBasicExPostVintage();
    
    await projectProxy.mintExAnte(accounts[1], exPostId, anteAmount,  web3.utils.fromAscii(""));

    let failed = true
    try {
    await projectProxy.mintExAnte(accounts[1], exPostId, 1,  web3.utils.fromAscii(""));
      failed = false
    }catch (e) {
    }
    assert(failed, `Should have failed to create ex ante with amount ${anteAmount} that exceeds maxAntePercentage of estimated vintages`);
  });

  it("should verify and mint a portion of the vintage", async function () {
    const {
      exPostId
    } = await createBasicExPostVintage();
    const {} = await verifyAndMintBasicExPost(exPostId);
  });

  it("should verify final amount and try to verify and mint again but fail because verificationPeriodEnd <= lastVerificationTimestamp onchain", async function () {
    const {
      exPostId,
      verificationPeriodEnd
    } = await createBasicExPostVintage();
    const {} = await verifyAndMintBasicExPost(exPostId, {verificationPeriodEnd: verificationPeriodEnd});
    let failed = true;
    try {
      await verifyAndMintBasicExPost(exPostId, {verificationPeriodEnd: verificationPeriodEnd+1});
      failed = false;
    }catch (e) {}
    assert(failed, `Should have failed to verify and mint vintage ${exPostId} that has already been verified with last verification date ${verificationPeriodEnd} set to max end of vintage`);
  });

  it("should fail to mint more exAnte because the vintage has completed verification", async function () {
    const {
      exPostId,
      verificationPeriodEnd
    } = await createBasicExPostVintage();
    const {} = await verifyAndMintBasicExPost(exPostId, {verificationPeriodEnd});
    let failed = true;
    try {
      await projectProxy.mintExAnte(accounts[1], exPostId, 1,  web3.utils.fromAscii(""));
      failed = false;
    }catch (e) {}
    assert(failed, `Should have failed to mint ex ante because vintage ${exPostId} has already been verified`);
  })

  it("should create post vintages using batch", async function () {
    const vintages = []
    for (let i = 0; i < 5; i++) {
vintages.push({
  estAmount:1000*(i+1),
  serialization:`ICR-ISL-2020-01-01-2020-12-31-1-2023-${generateRandomString()}`,
  verificationPeriodStart: Math.floor((new Date(2023+i, 0,1)).getTime()/1000),
  verificationPeriodEnd: Math.floor((new Date(2023+i, 11,31)).getTime()/1000)
})
    }

    const topTokenIdBefore = await projectProxy.topTokenId();

    const result = await projectProxy.createExPostVintageBatch([
      ...vintages.map(v => [
        v.serialization,
        v.estAmount,
        v.verificationPeriodStart,
        v.verificationPeriodEnd,
        0
      ]),
    ]);

    const topTokenIdAfter = await projectProxy.topTokenId();
    assert.equal(topTokenIdAfter.toNumber() - topTokenIdBefore.toNumber(), vintages.length, `Should have created ${vintages.length} vintages but created ${topTokenIdAfter.toNumber() - topTokenIdBefore.toNumber()}`);
    const exPostCreatedLogs = result.logs.filter(l => l.event === 'ExPostCreated');
    assert(exPostCreatedLogs.length === vintages.length, `Should have created ${vintages.length} vintages but created ${exPostCreatedLogs.length} vintages`)

    for(let i = 0; i < vintages.length; i++) {
      const vintage = vintages[i];
      const exPostCreatedLog = exPostCreatedLogs[i];
      const exPostId = exPostCreatedLog.args.tokenId.toNumber();
      const exPostEstimatedAmount = exPostCreatedLog.args.estimatedAmount.toNumber();
      const exPostSerialization = exPostCreatedLog.args.serialization; // Note: indexed string topics in event logs are indexed by keccak256 hash of the string i.e. the string itself is not visible in the log -> https://stackoverflow.com/questions/73232215/how-to-decode-the-indexed-string-param-in-an-event-using-web3-js
      const verificationPeriodStartFromLog = exPostCreatedLog.args.verificationPeriodStart.toNumber();
      const verificationPeriodEndFromLog = exPostCreatedLog.args.verificationPeriodEnd.toNumber();

      assert.equal(exPostEstimatedAmount, vintage.estAmount, `Saved estimated amount ${exPostEstimatedAmount} should be equal to ${vintage.estAmount}`);
      assert.equal(exPostSerialization, web3.utils.keccak256(vintage.serialization), `Saved serialization ${exPostSerialization} should be equal to ${vintage.serialization}`);
      assert.equal(verificationPeriodStartFromLog, vintage.verificationPeriodStart, `Saved verification period start ${verificationPeriodStartFromLog} should be equal to ${vintage.verificationPeriodStart}`);
      assert.equal(verificationPeriodEndFromLog, vintage.verificationPeriodEnd, `Saved verification period end ${verificationPeriodEndFromLog} should be equal to ${vintage.verificationPeriodEnd}`);
    }
  })

  it("should fail to create post vintages using batch because two vintages have same serialization", async function () {
    const vintages = []
    for (let i = 0; i < 5; i++) {
vintages.push({
  estAmount:1000*(i+1),
  serialization:i % 3 == 0 ? `ICR-ISL-2020-01-01-2020-12-31-1-2023-sameSer`:`ICR-ISL-2020-01-01-2020-12-31-1-2023-${generateRandomString()}`,
  verificationPeriodStart: Math.floor((new Date(2023+i, 0,1)).getTime()/1000),
  verificationPeriodEnd: Math.floor((new Date(2023+i, 11,31)).getTime()/1000)
})
    }

let failed = true;
    try {
      await projectProxy.createExPostVintageBatch([
        ...vintages.map(v => [
          v.serialization,
          v.estAmount,
          v.verificationPeriodStart,
          v.verificationPeriodEnd,
          0
        ]),
      ]);
      failed = false;
    }catch (e) {}
    assert(failed, `Should have failed to create vintages because two vintages have same serialization`);
  })







  /// ACCESS CONTROL TESTS!
  /// TEST BLACKLISTING
  // TEST SIGNATURE TRANSFER AND RETIRE

  async function verifyAndMintBasicExPost(exPostId, opt) {
    assert(exPostId, "exPostId is required")

    const values = {
      verificationStart: opt?.verificationStart ?? Math.floor((new Date(2023, 0, 1)).getTime() / 1000),
      verificationPeriodEnd: opt?.verificationPeriodEnd ?? Math.floor((new Date(2023, 5, 1)).getTime() / 1000), // 1.june 2023
      amountVerified: opt?.amountVerified ?? 1000,
      amountToAnteHolders : opt?.amountToAnteHolders ?? 0,
      monitoringReport: opt?.monitoringReport ?? "",
      verificationVault: opt?.verificationVault ?? accounts[0]
    }

    const {
      verificationStart,
      verificationPeriodEnd,
      amountVerified,
      amountToAnteHolders,
      monitoringReport,
      verificationVault
    } = values

    const balanceOfAccountPreMint = await projectProxy.balanceOf(verificationVault, exPostId);


    const verifyResult = await projectProxy.verifyAndMintExPost(verificationVault, exPostId, amountVerified, amountToAnteHolders, verificationStart, verificationPeriodEnd, monitoringReport);
    const ExPostVerifiedAndMintedLog = verifyResult.logs.find(l => l.event === 'ExPostVerifiedAndMinted');

    const exPostVerifiedId = ExPostVerifiedAndMintedLog.args.tokenId.toNumber();
    const amount = ExPostVerifiedAndMintedLog.args.amount.toNumber();
    const amountToAnteHoldersLogged = ExPostVerifiedAndMintedLog.args.amountToAnteHolders.toNumber();
    const verificationStartLogged = ExPostVerifiedAndMintedLog.args.verificationPeriodStart.toNumber();
    const verificationPeriodEndLogged = ExPostVerifiedAndMintedLog.args.verificationPeriodEnd.toNumber();
    const monitoringReportLogged = ExPostVerifiedAndMintedLog.args.monitoringReport;
    
    assert.equal(exPostVerifiedId, exPostId, `Saved ex post id ${exPostVerifiedId} should be equal to ${exPostId}`);
    assert.equal(amount, amountVerified, `Saved amount ${amount} should be equal to ${amountVerified}`);
    assert.equal(amountToAnteHoldersLogged, amountToAnteHolders, `Saved amount to ante holders ${amountToAnteHoldersLogged} should be equal to ${amountToAnteHolders}`);
    assert.equal(verificationStartLogged, verificationStart, `Saved verification start ${verificationStartLogged} should be equal to ${verificationStart}`);
    assert.equal(verificationPeriodEndLogged, verificationPeriodEnd, `Saved verification period end ${verificationPeriodEndLogged} should be equal to ${verificationPeriodEnd}`);
    assert.equal(monitoringReportLogged, monitoringReport, `Saved monitoring report ${monitoringReportLogged} should be equal to ${monitoringReport}`);

    const balanceOfAccount = await projectProxy.balanceOf(verificationVault, exPostId);
    assert.equal(balanceOfAccount.toNumber(), amountVerified + balanceOfAccountPreMint.toNumber(), `Saved balance of account ${balanceOfAccount} should be equal to ${amountVerified}`);

    return { ...values}
  }

  async function createBasicExPostVintage(opt){
    const values = {
      estAmount: opt?.estAmount ?? 10000,
      serialization:opt?.serialization ?? `ICR-ISL-2020-01-01-2020-12-31-1-2023-${generateRandomString()}`,
      verificationPeriodStart: opt?.verificationPeriodStart ?? Math.floor((new Date(2023, 0,1)).getTime()/1000),
      verificationPeriodEnd: opt?.verificationPeriodEnd ?? Math.floor((new Date(2023, 11,31)).getTime()/1000)
    }

  
    const result = await projectProxy.createExPostVintage(values.estAmount,values.verificationPeriodStart, values.verificationPeriodEnd, values.serialization);
    const exPostCreatedLog = result.logs.find(l => l.event === 'ExPostCreated');
    const exPostId = exPostCreatedLog.args.tokenId.toNumber();
    const exPostEstimatedAmount = exPostCreatedLog.args.estimatedAmount.toNumber();
    const exPostSerialization = exPostCreatedLog.args.serialization; // Note: indexed string topics in event logs are indexed by keccak256 hash of the string i.e. the string itself is not visible in the log -> https://stackoverflow.com/questions/73232215/how-to-decode-the-indexed-string-param-in-an-event-using-web3-js
    const verificationPeriodStartFromLog = exPostCreatedLog.args.verificationPeriodStart.toNumber();
    const verificationPeriodEndFromLog = exPostCreatedLog.args.verificationPeriodEnd.toNumber();

    assert.equal(exPostEstimatedAmount, values.estAmount, `Saved estimated amount ${exPostEstimatedAmount} should be equal to ${values.estAmount}`);
    assert.equal(exPostSerialization, web3.utils.keccak256(values.serialization), `Saved serialization ${exPostSerialization} should be equal to ${values.serialization}`);
    assert.equal(verificationPeriodStartFromLog, values.verificationPeriodStart, `Saved verification period start ${verificationPeriodStartFromLog} should be equal to ${values.verificationPeriodStart}`);
    assert.equal(verificationPeriodEndFromLog, values.verificationPeriodEnd, `Saved verification period end ${verificationPeriodEndFromLog} should be equal to ${values.verificationPeriodEnd}`);

    return {exPostId, ...values}
  }

  function generateRandomString(length = 4) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
  }
});

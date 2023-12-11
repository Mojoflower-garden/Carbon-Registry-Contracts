import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const CarbonContractRegistryProxyAddress =
  '0x0B0fCaCD2336A5f000661fF5E69aA70c28fD526D';

// This does sometimes not work immediately because the carbonregistry contract is not yet deployed
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;
  const TokenVault = await ethers.getContractFactory('TokenVault');

  const carbonContractRegistry = await ethers.getContractAt(
    'CarbonContractRegistry',
    CarbonContractRegistryProxyAddress
  );
  await carbonContractRegistry.waitForDeployment();

  const tokenVaultBeacon = await upgrades.deployBeacon(TokenVault as any);
  await tokenVaultBeacon.waitForDeployment();
  const tokenVaultBeaconAddress = await tokenVaultBeacon.getAddress();
  console.log('TokenVaultBeacon deployed to:', tokenVaultBeaconAddress);
  const tokenVaultBeaconImplementationAddress =
    await upgrades.beacon.getImplementationAddress(tokenVaultBeaconAddress);
  console.log(
    'TokenVaultBeacon implementation deployed to:',
    tokenVaultBeaconImplementationAddress
  );

  // Set the beacon address in the carbonContractRegistry
  await carbonContractRegistry.setTokenVaultBeaconAddress(
    tokenVaultBeaconAddress
  );
  console.log('DONE SETTING');
  const newVerifiedVaultResponse =
    await carbonContractRegistry.createNewVerifiedVault();
  console.log(
    'Created new Verified Vault',
    newVerifiedVaultResponse.hash,
    newVerifiedVaultResponse.from
  );

  const tokenVaultBeaconArtifact = await deployments.getExtendedArtifact(
    'TokenVault'
  );
  const projectBeaconArtifact = await deployments.getExtendedArtifact(
    'IBeaconUpgradeable'
  );

  const time = Date.now();
  await save(`${time}-VerifiedVault_beacon`, {
    address: tokenVaultBeaconAddress,
    ...projectBeaconArtifact,
  });
  await save(`${time}-VerifiedVault_implementation`, {
    address: tokenVaultBeaconImplementationAddress,
    ...tokenVaultBeaconArtifact,
  });

  // Just for documentation purposes
  // await upgrades.deployBeaconProxy(tokenVaultBeacon as any, TokenVault as any, [
  //   await carbonContractRegistry.getAddress(),
  // ]);
  // console.log(
  //   'Beacon documentation TokenVault deployed to:',
  //   await tokenVaultBeacon.getAddress()
  // );
};
export default main;
main.tags = ['TokenVault'];

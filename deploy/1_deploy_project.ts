import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;
  const Project = await ethers.getContractFactory('Project');

  const projectBeacon = await upgrades.deployBeacon(Project as any); // The beacon itself!
  await projectBeacon.waitForDeployment();
  const projectBeaconAddress = await projectBeacon.getAddress();
  console.log('Project Beacon deployed to:', projectBeaconAddress);
  const projectBeaconImplementationAddress =
    await upgrades.beacon.getImplementationAddress(projectBeaconAddress);
  console.log(
    'Project Beacon implementation deployed to:',
    projectBeaconImplementationAddress
  );

  const projectBeaconImplementationArtifact =
    await deployments.getExtendedArtifact('Project');
  const projectBeaconArtifact = await deployments.getExtendedArtifact(
    'IBeaconUpgradeable'
  );

  const time = Date.now();

  await save(`${time}-Project_beacon`, {
    address: projectBeaconAddress,
    ...projectBeaconArtifact,
  });
  await save(`${time}-Project_implementation`, {
    address: projectBeaconImplementationAddress,
    ...projectBeaconImplementationArtifact,
  });

  // Just for documentation purposes
  // await upgrades.deployBeaconProxy(projectBeacon as any, Project as any, [
  //   await carbonContractRegistry.getAddress(),
  //   await deployer.getAddress(),
  //   192831927864,
  //   'Test Project Name',
  //   'Test Project Methodology',
  //   'Test Project URI',
  // ]);
  // console.log(
  //   'Beacon documentation Project deployed to:',
  //   await projectBeacon.getAddress()
  // );
};
export default main;
main.tags = ['Project'];

import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;

  console.log('UPDATE!');

  const Project = await ethers.getContractFactory('Project');

  const projectAddress = '0x983a099b75bee66b265c23474917bb3e84a47708';
  const projectBeaconAddress = await upgrades.erc1967.getBeaconAddress(
    projectAddress
  );
  console.log('Project Beacon Address', projectBeaconAddress);
  //   const projectBeaconAddress = '';

  const projectBeaconImplementationAddress =
    await upgrades.beacon.getImplementationAddress(projectBeaconAddress);

  console.log(
    'Project Beacon implementation deployed to:',
    projectBeaconImplementationAddress
  );

  await upgrades.upgradeBeacon(projectBeaconAddress, Project);
  console.log('Beacon upgraded');

  //   const projectBeaconImplementationArtifact =
  //     await deployments.getExtendedArtifact('Project');
  //   const projectBeaconArtifact = await deployments.getExtendedArtifact(
  //     'IBeaconUpgradeable'
  //   );

  //   const time = Date.now();

  //   await save(`${time}-Project_beacon`, {
  //     address: projectBeaconAddress,
  //     ...projectBeaconArtifact,
  //   });
  //   await save(`${time}-Project_implementation`, {
  //     address: projectBeaconImplementationAddress,
  //     ...projectBeaconImplementationArtifact,
  //   });
};
export default main;
main.tags = ['UpgradeProjectBeacon'];

import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;

  console.log('UPDATE!');

  const Project = await ethers.getContractFactory('Project');

  const projectAddress =
    hre.network.name === 'mumbai'
      ? '0x983a099b75bee66b265c23474917bb3e84a47708'
      : hre.network.name === 'polygon'
      ? '0xb4A2E587B56d40e33395645c11c822bCC520E2ef'
      : '';
  const projectBeaconAddress = await upgrades.erc1967.getBeaconAddress(
    projectAddress
  );
  console.log('Project Beacon Address', projectBeaconAddress);

  const projectBeaconImplementationAddress =
    await upgrades.beacon.getImplementationAddress(projectBeaconAddress);

  console.log(
    'Project Beacon implementation deployed to:',
    projectBeaconImplementationAddress
  );

  await upgrades.upgradeBeacon(projectBeaconAddress, Project);
  console.log('Beacon upgraded');
};
export default main;
main.tags = ['UpgradeProjectBeacon'];

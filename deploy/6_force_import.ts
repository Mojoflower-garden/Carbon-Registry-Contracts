import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const Project = await ethers.getContractFactory('Project');
  await upgrades.forceImport(
    hre.network.name === 'baseSepolia'
      ? '0xa4686bcfa897d1cc56ec09b306d0c5a8096cb5aa'
      : hre.network.name === 'polygon'
      ? '0xb4A2E587B56d40e33395645c11c822bCC520E2ef'
      : '',
    Project
  );
};
export default main;
main.tags = ['ForceImportProject', '6'];

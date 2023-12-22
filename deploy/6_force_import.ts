import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const OldProject = await ethers.getContractFactory('OldProject');
  await upgrades.forceImport(
    hre.network.name === 'mumbai'
      ? '0x983a099b75bee66b265c23474917bb3e84a47708'
      : hre.network.name === 'polygon'
      ? '0xb4A2E587B56d40e33395645c11c822bCC520E2ef'
      : '',
    OldProject
  );
};
export default main;
main.tags = ['ForceImportProject'];

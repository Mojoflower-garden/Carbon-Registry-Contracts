import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;
  const OldProject = await ethers.getContractFactory('OldProject');
  await upgrades.forceImport(
    '0x983a099b75bee66b265c23474917bb3e84a47708',
    OldProject
  );
};
export default main;
main.tags = ['ForceImportProject'];

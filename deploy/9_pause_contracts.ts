import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import MumbaiHolders from './data/mumbaiHoldersPreDebasement.json';
import PolygonHolders from './data/polygonHoldersPreDebasement.json';

/**
 * DebaseMent of mumbai was done on -> 47000457 also all holders of project -> 0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b were given 10^18*10^18 TCO2e by mistake.
 */

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('9');

  const allHolders =
    hre.network.name === 'mumbai'
      ? MumbaiHolders
      : hre.network.name === 'polygon'
      ? PolygonHolders
      : [];

  let gasEstimation = ethers.toBigInt(0);
  const projectsToPause = allHolders.map((holder) => holder.projectAddress);
  for (const projectAddress of projectsToPause) {
    try {
      const project = await ethers.getContractAt('Project', projectAddress);
      const res = await project.paused();
      // const res = await project.pause.estimateGas();
      // gasEstimation += res;
      console.log('RES:', res);
    } catch (error) {
      console.log('ERROR:', error);
      continue;
    }
  }
  console.log('GAS:', gasEstimation);
};
export default main;
main.tags = ['PauseContracts', '9'];

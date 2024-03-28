import { ethers } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import MumbaiHolders from './data/mumbaiHoldersPreDebasement.json';
import PolygonHolders from './data/polygonHoldersPreDebasement.json';

/**
 * DebaseMent of mumbai was done on -> 47000457 also all holders of project -> 0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b were given 10^18*10^18 TCO2e by mistake.
 */
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('10');

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
      const isPaused = await project.paused();
      if (isPaused) {
        console.log('Project is paused');
        const res = await project.unpause({
          maxFeePerGas: ethers.parseUnits('200', 'gwei'),
          maxPriorityFeePerGas: ethers.parseUnits('200', 'gwei'),
        });
        console.log('RES:', res);
      } else {
        console.log('Project is not paused');
      }
      // const res = await project.unpause.estimateGas();
      // gasEstimation += res;
    } catch (error) {
      console.log('ERROR:', error);
      continue;
    }

    continue;
  }
  console.log('GAS:', gasEstimation);
};
export default main;
main.tags = ['UnpauseContracts', '10'];

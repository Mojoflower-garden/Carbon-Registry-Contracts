import { ethers, upgrades, deployments } from 'hardhat';
import { AccessController } from '../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('!!!!!14!!!!!');
  const { save } = deployments;
  // const AccessController = await ethers.getContractFactory('AccessController');

  const CarbonRegistryContract = await ethers.getContractAt(
    'CarbonContractRegistry',
    '0x826b76bA7B9e9e1f19407FBA3d3011E37536dB58'
  );

  const oldGaia = '0x333D9A49b6418e5dC188989614f07c89d8389CC8';
  const icrAdmin = '0xd00749D7eb0D333D8997B0d5Aec0fa86cf026c76';
  const icrMinter = '0xD104B5B4cda8AB7197Eb30C371c2Fd7fecAf5761';
  const devAccessController = '0x0D0c06bE10d8380e9047ae15BF5eD971913F76b1';
  const accessController = devAccessController;

  const hasRole = await CarbonRegistryContract.hasRole(
    await CarbonRegistryContract.DEFAULT_ADMIN_ROLE(),
    devAccessController
  );

  console.log('HASROLE:', hasRole);
};
export default main;
main.tags = ['CheckRoles', '14'];
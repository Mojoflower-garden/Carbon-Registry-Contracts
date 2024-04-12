import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const CarbonContractRegistryProxyAddress =
  '0x826b76bA7B9e9e1f19407FBA3d3011E37536dB58';

// This does sometimes not work immediately because the carbonregistry contract is not yet deployed
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;
  const TokenVault = await ethers.getContractFactory('TokenVault');

  const carbonContractRegistry = await ethers.getContractAt(
    'CarbonContractRegistry',
    CarbonContractRegistryProxyAddress
  );
  await carbonContractRegistry.waitForDeployment();

  const t = await carbonContractRegistry.getVerifiedVaultAddress(1);

  console.log('T:', t);
};
export default main;
main.tags = ['GetVaultAddress'];

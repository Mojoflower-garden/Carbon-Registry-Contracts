import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('7');
  const { save } = deployments;
  const Project = await ethers.getContractFactory('Project');
  const isProdTest = false;

  const isMainnet = hre.network.name === 'polygon';
  const projectAddress = isProdTest
    ? // ? '0x0B0fCaCD2336A5f000661fF5E69aA70c28fD526D'
      '0x225346387256b303ad8aee735b509b4282534382'
    : hre.network.name === 'baseSepolia'
    ? '0xa4686bcfa897d1cc56ec09b306d0c5a8096cb5aa'
    : isMainnet
    ? '0xb4A2E587B56d40e33395645c11c822bCC520E2ef'
    : '';
  const projectBeaconAddress = await upgrades.erc1967.getBeaconAddress(
    projectAddress
  );
  console.log(
    'Project Beacon Address',
    projectBeaconAddress,
    await hre.ethers.getSigners()
  );

  const projectBeaconImplementationAddress =
    await upgrades.beacon.getImplementationAddress(projectBeaconAddress);

  console.log(
    'Project Beacon implementation deployed to:',
    projectBeaconImplementationAddress
  );
  const res = await upgrades.upgradeBeacon(projectBeaconAddress, Project, {
    txOverrides: {
      maxFeePerGas: ethers.parseUnits(isMainnet ? '200' : '2', 'gwei'),
      maxPriorityFeePerGas: ethers.parseUnits(isMainnet ? '200' : '2', 'gwei'),
      // gasLimit: 5000000n,
    },
  });
  console.log('Beacon upgraded', await res.getAddress());
};
export default main;
main.tags = ['UpgradeProjectBeacon', '7'];

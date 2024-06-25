import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('WE HERE!');
  const { save } = deployments;
  const Project = await ethers.getContractFactory('Project');

  const isProdTest = false;

  const projectAddress = isProdTest
    ? // ? '0x0B0fCaCD2336A5f000661fF5E69aA70c28fD526D'
      '0x225346387256b303ad8aee735b509b4282534382'
    : hre.network.name === 'baseSepolia'
    ? '0xf66411a1eab7d9e727f8ba346f115f988b755698'
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
main.tags = ['UpgradeProjectBeacon', '5'];

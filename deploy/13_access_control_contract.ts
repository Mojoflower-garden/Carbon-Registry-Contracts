import { ethers, upgrades, deployments } from 'hardhat';
import { AccessController } from '../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('!!!!!13!!!!!');
  const { save } = deployments;
  const AccessController = await ethers.getContractFactory('AccessController');

  const accessController: AccessController = (await upgrades.deployProxy(
    AccessController as any,
    [],
    {
      kind: 'uups',
    }
  )) as any; // The accessController and the implementation are deployed
  await accessController.waitForDeployment();
  const accessControllerAddress = await accessController.getAddress();
  console.log('AccessControllerProxy deployed to:', accessControllerAddress);
  const accessControllerImplementationAddress =
    await upgrades.erc1967.getImplementationAddress(accessControllerAddress);
  console.log(
    'AccessController implementation deployed to:',
    accessControllerImplementationAddress
  );

  const accessControllerArtifact = await deployments.getExtendedArtifact(
    'AccessController'
  );

  const time = Date.now();
  await save(`${time}-AccessController_proxy`, {
    address: accessControllerAddress,
    ...accessControllerArtifact,
  });
  await save(`${time}-AccessController_implementation`, {
    address: accessControllerImplementationAddress,
    ...accessControllerArtifact,
  });
};
export default main;
main.tags = ['AccessController', '13'];

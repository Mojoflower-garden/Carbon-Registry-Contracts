import { ethers, upgrades, deployments } from 'hardhat';
import { BatchCreditActions } from '../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log(await hre.ethers.getSigners());
  const { save } = deployments;
  const BatchCreditActionsContract = await ethers.getContractFactory(
    'BatchCreditActions'
  );

  const batchCreditActionsContractRegistry: BatchCreditActions =
    (await upgrades.deployProxy(BatchCreditActionsContract as any, [], {
      kind: 'uups',
    })) as any; // The batchCreditActionsContractRegistry and the implementation are deployed
  await batchCreditActionsContractRegistry.waitForDeployment();

  const batchCreditActionsContractRegistryAddress =
    await batchCreditActionsContractRegistry.getAddress();
  console.log(
    'BatchCreditActionsContractRegistryProxy deployed to:',
    batchCreditActionsContractRegistryAddress
  );

  const batchCreditActionsContractRegistryImplementationAddress =
    await upgrades.erc1967.getImplementationAddress(
      batchCreditActionsContractRegistryAddress
    );
  console.log(
    'BatchCreditActionsContractRegistry implementation deployed to:',
    batchCreditActionsContractRegistryImplementationAddress
  );

  const batchCreditActionsContractRegistryArtifact =
    await deployments.getExtendedArtifact('BatchCreditActions');

  const time = Date.now();
  await save(`${time}-BatchCreditActionsContractRegistry_proxy`, {
    address: batchCreditActionsContractRegistryAddress,
    ...batchCreditActionsContractRegistryArtifact,
  });
  await save(`${time}-BatchCreditActionsContractRegistry_implementation`, {
    address: batchCreditActionsContractRegistryImplementationAddress,
    ...batchCreditActionsContractRegistryArtifact,
  });
};
export default main;
main.tags = ['BatchCredits', '21'];

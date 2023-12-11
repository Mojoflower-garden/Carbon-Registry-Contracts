import { ethers, upgrades, deployments } from 'hardhat';
import { CarbonContractRegistry } from '../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const ProjectBeaconAddress = '0xC5E5C6f84d5A5884c889Fb6F032f4ACC202b75aF';
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { save } = deployments;
  const CarbonContractRegistry = await ethers.getContractFactory(
    'CarbonContractRegistry'
  );

  const carbonContractRegistry: CarbonContractRegistry =
    (await upgrades.deployProxy(
      CarbonContractRegistry as any,
      [ProjectBeaconAddress],
      {
        kind: 'uups',
      }
    )) as any; // The carbonContractRegistry and the implementation are deployed
  await carbonContractRegistry.waitForDeployment();
  const carbonContractRegistryAddress =
    await carbonContractRegistry.getAddress();
  console.log(
    'CarbonContractRegistryProxy deployed to:',
    carbonContractRegistryAddress
  );
  const carbonContractRegistryImplementationAddress =
    await upgrades.erc1967.getImplementationAddress(
      carbonContractRegistryAddress
    );
  console.log(
    'CarbonContractRegistry implementation deployed to:',
    carbonContractRegistryImplementationAddress
  );

  const carbonContractRegistryArtifact = await deployments.getExtendedArtifact(
    'CarbonContractRegistry'
  );

  const time = Date.now();
  await save(`${time}-CarbonContractRegistry_proxy`, {
    address: carbonContractRegistryAddress,
    ...carbonContractRegistryArtifact,
  });
  await save(`${time}-CarbonContractRegistry_implementation`, {
    address: carbonContractRegistryImplementationAddress,
    ...carbonContractRegistryArtifact,
  });
};
export default main;
main.tags = ['CarbonContractRegistry'];

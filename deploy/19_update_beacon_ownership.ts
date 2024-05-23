import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('19');
  const { save } = deployments;
  const Project = await ethers.getContractFactory('Project');

  const isProdTest = true;

  const projectAddress = isProdTest
    ? '0x225346387256b303ad8aee735b509b4282534382'
    : hre.network.name === 'baseSepolia'
    ? '0xf66411a1eab7d9e727f8ba346f115f988b755698'
    : hre.network.name === 'polygon'
    ? '0xb4A2E587B56d40e33395645c11c822bCC520E2ef'
    : '';

  const projectBeaconAddress = await upgrades.erc1967.getBeaconAddress(
    projectAddress
  );
  console.log('Project Beacon Address', projectBeaconAddress, projectAddress);

  const signer = new hre.ethers.Wallet(
    '', // Gaia private key
    hre.ethers.provider
  );

  const t = await ethers.getContractAt(
    'OwnableUpgradeable',
    projectBeaconAddress,
    signer
  );

  // console.log('NONCE:', await signer.getNonce());
  // return;
  const icrAdmin = (await hre.ethers.getSigners())[0].address;

  const ownerBefore = await t.owner();

  console.log('OWNERBefore:', ownerBefore, icrAdmin);

  const transaction = await t.transferOwnership(icrAdmin, {
    gasPrice: ethers.parseUnits('500', 'gwei'), // Set the gas price to 50 gwei
    nonce: await signer.getNonce(),
  });

  console.log('TX:', transaction.hash);

  await transaction.wait();

  const ownerAfter = await t.owner();

  console.log('OWNERAfter:', ownerAfter);
};
export default main;
main.tags = ['19'];

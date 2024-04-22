import { ethers, upgrades, deployments } from 'hardhat';
import { AccessController } from '../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('!!!!!16!!!!!');
  const { save } = deployments;

  const prodProjectContracts = [
    '0x0b036f17cb8074ce60658898b852e41953f8e629',
    '0x2f5e9ab6c687f40f9119e06630c68054b16a4270',
    '0x35f8f85d3d077d4aea57f89ed5f30ed97d136d8a',
    '0x625dda3d3812ce640ca5c7c4729cbecacabdef0a',
    '0x68341e98f9ebaa9cae9638808b751bf9568d0557',
    '0x71da00d8288fdf542bb8d0f8dffc09f9c58aed4d',
    '0x7405c58fcfd86c81bc09924a0a1f49350bd2f464',
    '0x811893265f3689f7c23acc5f0af46adbd2b9d791',
    '0x8af1cf390f8f90f4c9b9a2c9c2a9a55b026166e5',
    '0x8cc608c9594d042fae6fa127512be0476fba9f68',
    '0x9d58dc930887f06d85a44a4a57cde4db7cba7d9f',
    '0xa2e71e7a0a2df394c21e983a947ad0913961fbb9',
    '0xae63fbd056512fc4b1d15b58a98f9aaea44b18a9',
    '0xb4a2e587b56d40e33395645c11c822bcc520e2ef',
    '0xd016b2acece65612b93cc9aee763bda0c2b0e4c0',
    '0xe47b7ce9a7f59519091ed7cbdea8516734d978c4',
    '0xe564fce6fbe7b11c54b410a03e93f14a74396024',
  ];

  const devProjectContracts = [
    '0x092f9254a4fa26c43985bafcb4458587e3aa5920',
    '0x3fbe463d60475d8193d230f83a409de518ca876f',
    '0x49a88d0dd5f316556794877940d515d1a9b2c3c3',
    '0x7a7186698fff22ed5b09a885ad30976b0a99d9da',
    '0x83aa7adc0fb5511983ce9fc3e824bafce5707c91',
    '0x857dc09c18784cad75f9a0c69a87b0db76ace9c9',
    '0x8805ef483b699162a34e9752dadf81ed8cb4b581',
    '0xa9383eaf67f51bb36d0852843f586a05010d6f4b',
    '0xaaef187debc660557f728358e0b2533f6d72a75b',
    '0xdb25dbb9404b26d2ccbbbc611f9f8f5865c6d5c6',
    '0xf66411a1eab7d9e727f8ba346f115f988b755698',
    '0xf848bfeef608cc8b7efbdd2c11c59cb669a3a562',
  ];

  const devCarbonRegistryContract =
    '0x826b76bA7B9e9e1f19407FBA3d3011E37536dB58';
  const prodCarbonRegistryContract =
    '0x9f87988FF45E9b58ae30fA1685088460125a7d8A';

  const oldGaia = '0x333D9A49b6418e5dC188989614f07c89d8389CC8';
  const devICRAdmin = '0xd00749D7eb0D333D8997B0d5Aec0fa86cf026c76';
  const devICRMinter = '0xD104B5B4cda8AB7197Eb30C371c2Fd7fecAf5761';
  const prodICRAdmin = '0xA0022c05501007281acAE55B94AdE4Fc3dd59ec3';
  const icrAdmin = prodICRAdmin;
  const devAccessController = '0x0D0c06bE10d8380e9047ae15BF5eD971913F76b1';
  const prodAccessController = '0x7310e77c305FeDD3a2b1F9FA983B4652D8ce5829';

  const carbonRegContract = prodCarbonRegistryContract;
  const projectContracts = prodProjectContracts;
  const accessController = prodAccessController;

  for (const project of [...projectContracts, carbonRegContract]) {
    const accessControllerContract = await ethers.getContractAt(
      'AccessControlUpgradeable',
      project
    );
    const hasRole = await accessControllerContract.hasRole(
      await accessControllerContract.DEFAULT_ADMIN_ROLE(),
      oldGaia
    );
    console.log('HASROLE', hasRole);
  }
  return;

  try {
    const accessControllerContract = await ethers.getContractAt(
      'AccessController',
      accessController
    );

    const grantAdminTx = await accessControllerContract.grantAdminRole(
      [...projectContracts, carbonRegContract],
      icrAdmin,
      {
        gasPrice: ethers.parseUnits('420', 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('Granting admin roles tx:', grantAdminTx);
    await grantAdminTx.wait();

    console.log('Granting carbon registry roles');
    const grantCarbonRegTx = await accessControllerContract.grantCarbonRegRoles(
      carbonRegContract,
      icrAdmin,
      {
        gasPrice: ethers.parseUnits('420', 'gwei'), // Set the gas price to 50 gwei
      }
    );
    await grantCarbonRegTx.wait();

    console.log('Granting project roles');
    const grantProjectTx = await accessControllerContract.grantProjectRoles(
      projectContracts,
      icrAdmin,
      {
        gasPrice: ethers.parseUnits('420', 'gwei'), // Set the gas price to 50 gwei
      }
    );
    await grantProjectTx.wait();
  } catch (error) {
    console.log('ERROR:', error);
  }
};
export default main;
main.tags = ['GrantAdminRoles', '16'];

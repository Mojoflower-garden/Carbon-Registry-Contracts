import { ethers, upgrades, deployments } from 'hardhat';
import { AccessController } from '../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';

const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('!!!!!18!!!!!');

  const { save } = deployments;

  const gasAmount = hre.network.name === 'polygon' ? '500' : '5';

  const signer = new hre.ethers.Wallet(
    '', // Gaia private key
    hre.ethers.provider
  );

  const oldGaia = '0x333D9A49b6418e5dC188989614f07c89d8389CC8';
  const devICRAdmin = '0xd00749D7eb0D333D8997B0d5Aec0fa86cf026c76';
  const prodICRAdmin = '0xA0022c05501007281acAE55B94AdE4Fc3dd59ec3';
  const icrAdmin = prodICRAdmin;

  const testTokenVaultProd = '0x0C2Dba6E1A68ad7effe1d53368D625Ee563C6b38';
  const tokenVaultDev = '0x1DfDA80820C475c076B3822491555fD414aE26D6';
  const tokenVaultProd = '0x219BaB4AC1FD5b83940ea52A1E1B5Ea6d5ACE23F';
  const tokenVault = testTokenVaultProd;
  const tokenVaultContract = await ethers.getContractAt(
    'TokenVault',
    tokenVault,
    signer
  );

  const hasRole = await tokenVaultContract.hasRole(
    await tokenVaultContract.DEFAULT_ADMIN_ROLE(),
    oldGaia
  );

  console.log('HAS DEFAULT ADMIN ROLE:', hasRole);

  if (!hasRole) {
    const tx = await tokenVaultContract.grantRole(
      await tokenVaultContract.DEFAULT_ADMIN_ROLE(),
      icrAdmin,
      {
        gasPrice: ethers.parseUnits(gasAmount, 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('TX:', tx.hash);
    await tx.wait();
  }

  const hasFundMoverRole = await tokenVaultContract.hasRole(
    await tokenVaultContract.FUND_MOVER_ROLE(),
    icrAdmin
  );

  console.log('HAS FUND MOVER ROLE:', hasRole);

  if (!hasFundMoverRole) {
    const tx = await tokenVaultContract.grantRole(
      await tokenVaultContract.FUND_MOVER_ROLE(),
      icrAdmin,
      {
        gasPrice: ethers.parseUnits(gasAmount, 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('TX:', tx.hash);
    await tx.wait();
  }

  const hasUpgraderRole = await tokenVaultContract.hasRole(
    await tokenVaultContract.UPGRADER_ROLE(),
    icrAdmin
  );

  console.log('HAS FUND MOVER ROLE:', hasRole);

  if (!hasUpgraderRole) {
    const tx = await tokenVaultContract.grantRole(
      await tokenVaultContract.UPGRADER_ROLE(),
      icrAdmin,
      {
        gasPrice: ethers.parseUnits(gasAmount, 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('TX:', tx.hash);
    await tx.wait();
  }

  const hasOldAdminRole = await tokenVaultContract.hasRole(
    await tokenVaultContract.DEFAULT_ADMIN_ROLE(),
    oldGaia
  );

  console.log('HAS OLD GAIA ADMIN ROLE', hasOldAdminRole);

  if (hasOldAdminRole) {
    const tx = await tokenVaultContract.revokeRole(
      await tokenVaultContract.UPGRADER_ROLE(),
      oldGaia,
      {
        gasPrice: ethers.parseUnits(gasAmount, 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('TX:', tx.hash);
    await tx.wait();

    const tx2 = await tokenVaultContract.revokeRole(
      await tokenVaultContract.FUND_MOVER_ROLE(),
      oldGaia,
      {
        gasPrice: ethers.parseUnits(gasAmount, 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('TX:', tx2.hash);
    await tx2.wait();

    const tx3 = await tokenVaultContract.revokeRole(
      await tokenVaultContract.DEFAULT_ADMIN_ROLE(),
      oldGaia,
      {
        gasPrice: ethers.parseUnits(gasAmount, 'gwei'), // Set the gas price to 50 gwei
      }
    );
    console.log('TX:', tx3.hash);
    await tx3.wait();
  }

  // Grant for CarbonRegistryContract
};
export default main;
main.tags = ['TokenVaultAccess', '18'];

import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import PolygonRetirementsHolders from './data/polygonRetirementsHolders.json';

/**
 * DebaseMent of mumbai was done on -> 47000457 also all holders of project -> 0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b were given 10^18*10^18 TCO2e by mistake.
 */

/**
 *
 * Debasement of mainnet polygon was started on block 55147487 and ended on block 55151181
 */
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('12');

  let gasEstimation = ethers.toBigInt(0);

  const addressesDone = [
    '0x35f8f85d3d077d4aea57f89ed5f30ed97d136d8a', // Carbon avoidance through the nutritional replacement of beef by carbon neutral Icelandic Spirulina (blue-green algae) production
    '0x8cc608c9594d042fae6fa127512be0476fba9f68', // Substitution of fossil fuels for the use of sustainable biofuels manufactured by Green Fuel Extremad
    '0xd016b2acece65612b93cc9aee763bda0c2b0e4c0', // Ovid Wind Farm Project
    '0xe47b7ce9a7f59519091ed7cbdea8516734d978c4', // Substitution of fossil fuels for the use of sustainable biofuels manufactured by Biotrading 2007 S.L
    '0x8af1cf390f8f90f4c9b9a2c9c2a9a55b026166e5', // Substitution of fossil fuels for the use of sustainable biofuels manufactured by Iniciativas Bioener
    '0xe564fce6fbe7b11c54b410a03e93f14a74396024', // Substitution of fossil fuels for the use of sustainable biofuels manufactured by Gunvor Biodiesel Be
  ];
  const currentAddress = '';

  for (const projectHolders of PolygonRetirementsHolders) {
    console.log('PROJECT:', projectHolders.projectAddress);
    if (
      projectHolders.projectAddress.toLowerCase() !==
      currentAddress.toLowerCase()
    )
      continue;
    if (
      projectHolders.holders.find(
        (holder) => holder.asset.type !== 'RetirementCertificate'
      )
    ) {
      console.log('Skipping project with non Retirement certificate');
      break;
    }
    const addresses = projectHolders.holders
      .filter((holder) => parseInt(holder.balance) > 0)
      .map((holder) => holder.accountAddress);
    const tokenIds = projectHolders.holders
      .filter((holder) => parseInt(holder.balance) > 0)
      .map((holder) => holder.asset.tokenId);
    const decimals = 18;

    console.log('Addresses:', addresses);
    console.log('TokenIds:', tokenIds);
    const project = await ethers.getContractAt(
      'Project',
      projectHolders.projectAddress
    );
    for (let i = 0; i < addresses.length; i++) {
      const balance = await project.retirementMapping(tokenIds[i]);
      console.log('Balance:', balance.toString());
    }
    continue;

    console.log(
      decimals > 0,
      addresses.length == tokenIds.length,
      tokenIds.length > 0
    );
    try {
      const res = await project.debaseRetirementTCO2(
        addresses,
        tokenIds,
        decimals.toString(),
        {
          maxFeePerGas: ethers.parseUnits('200', 'gwei'),
          maxPriorityFeePerGas: ethers.parseUnits('200', 'gwei'),
        }
      );
      console.log('RES:', res);
    } catch (error) {
      console.log('ERROR:', error);
      continue;
    }
  }
  console.log('GAS:', gasEstimation);
};
export default main;
main.tags = ['DebaseCredits', '12'];

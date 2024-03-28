import { ethers } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import MumbaiHolders from './data/mumbaiHoldersPreDebasement.json';
import PolygonHolders from './data/polygonHoldersPreDebasement.json';

/**
 * DebaseMent of mumbai was done on -> 47000457 also all holders of project -> 0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b were given 10^18*10^18 TCO2e by mistake.
 */
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('11');

  const txHash =
    '0x3520cdbfc04fa40c4c18fd547a129bf38e3112d7ffdd519de232f6f3ffb111ce';
  const network = await ethers.provider.getNetwork();
  // const pendingTx = await ethers.provider.getTransaction(txHash);

  // if (!pendingTx) {
  //   console.log('Transaction not found or already confirmed');
  //   return;
  // }

  const signer = await ethers.provider.getSigner(
    '0x333D9A49b6418e5dC188989614f07c89d8389CC8'
  );
  // const nonce = pendingTx.nonce;
  // const gasPrice = ethers.toBigInt(pendingTx.gasPrice) * ethers.toBigInt(2); // Increase the gas price

  const tx = {
    nonce: 501,
    gasPrice: ethers.parseUnits('150', 'gwei'),
    to: '0x333D9A49b6418e5dC188989614f07c89d8389CC8', // Send the transaction to yourself
    value: 0, // Don't send any value
    data: '0x', // No data
  };

  const cancelTx = await signer.sendTransaction(tx);
  console.log('Cancel transaction sent, hash:', cancelTx.hash);
};
export default main;
main.tags = ['CancelTransaction', '11'];

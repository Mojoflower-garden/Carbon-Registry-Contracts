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
    '0x8cdaaa420cd70cfb577584b1a455f01cd59e71640f0eb5deca9ce709f4de5409';
  const network = await ethers.provider.getNetwork();
  const pendingTx = await ethers.provider.getTransaction(txHash);

  if (!pendingTx) {
    console.log('Transaction not found or already confirmed');
    return;
  }

  const signer = new hre.ethers.Wallet(
    '0x2ebdc9b9334ebf87f40d38bd32803cace12c5792c67fef44d9c162f45a4f99cc', // Gaia private key
    hre.ethers.provider
  );
  // const signer = await ethers.provider.getSigner(pendingTx.from);
  const nonce = pendingTx.nonce;
  const gasPrice = ethers.toBigInt(pendingTx.gasPrice) * ethers.toBigInt(2); // Increase the gas price

  const tx = {
    nonce: nonce,
    gasPrice: gasPrice,
    to: pendingTx.from, // Send the transaction to yourself
    value: 0, // Don't send any value
    data: '0x', // No data
  };

  const cancelTx = await signer.sendTransaction(tx);
  console.log('Cancel transaction sent, hash:', cancelTx.hash);
};
export default main;
main.tags = ['CancelTransaction', '11'];

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
    '0xd4e72b9527cd311c50953ef0b436905d0f9b5e92671dfa6c2921708d42abbf70';
  const network = await ethers.provider.getNetwork();
  const pendingTx = await ethers.provider.getTransaction(txHash);

  if (!pendingTx) {
    console.log('Transaction not found or already confirmed');
    return;
  }

  const signer = new hre.ethers.Wallet(
    '', // Gaia private key
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

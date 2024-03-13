import { ethers, upgrades, deployments } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import MumbaiHolders from './data/mumbaiHoldersPreDebasement.json';

/**
 * DebaseMent of mumbai was done on -> 47000457 also all holders of project -> 0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b were given 10^18*10^18 TCO2e by mistake.
 */
const PolygonHolders: typeof MumbaiHolders = [];

// const getOverrideTXData = async () => {
//     const maxFeePerGas = ethers.parseUnits('1000', 'gwei');
//     let feeData = await this.wallet.getFeeData();
//     let gasPrice = this.increaseGasLimit(feeData.gasPrice);
//     if (gasPrice.gt(maxFeePerGas)) {
//       await this.awaitFor(3);
//       feeData = await this.wallet.getFeeData();
//       gasPrice = this.increaseGasLimit(feeData.gasPrice);
//       if (gasPrice.gt(maxFeePerGas)) {
//         throw new BadRequestException('Gas price too high');
//       }
//     }
//     return {
//       gasPrice: gasPrice,
//       nonce: await this.wallet.getTransactionCount(),
//     };
//   }
const main: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  console.log('8');
  //   const { save } = deployments;
  //   const Project = await ethers.getContractFactory('Project');

  //   const maxFeePerGas = ethers.parseUnits('1000', 'gwei');
  //   let feeData = await hre.
  //   let gasPrice = this.increaseGasLimit(feeData.gasPrice);
  //   if (gasPrice.gt(maxFeePerGas)) {
  //     await this.awaitFor(3);
  //     feeData = await this.wallet.getFeeData();
  //     gasPrice = this.increaseGasLimit(feeData.gasPrice);
  //     if (gasPrice.gt(maxFeePerGas)) {
  //       throw new BadRequestException('Gas price too high');
  //     }
  //   }

  const allHolders =
    hre.network.name === 'mumbai'
      ? MumbaiHolders
      : hre.network.name === 'polygon'
      ? PolygonHolders
      : [];

  let gasEstimation = ethers.toBigInt(0);
  for (const projectHolders of MumbaiHolders) {
    console.log('PROJECT:', projectHolders.projectAddress);
    if (
      projectHolders.holders.find(
        (holder) =>
          holder.asset.type !== 'ExAnte' && holder.asset.type !== 'ExPost'
      )
    ) {
      console.log('Skipping project with non ExAnte or ExPost assets');
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

    console.log(await project.balanceOf(addresses[0], tokenIds[0]));

    console.log(
      decimals > 0,
      addresses.length == tokenIds.length,
      tokenIds.length > 0
    );

    try {
      const res = await project.debaseTCO2(
        addresses,
        tokenIds,
        decimals.toString(),
        // STRing should be bytes
        ethers.toUtf8Bytes('Each token will not represent 10^-18 TCO2e')
      );
      console.log('RES:', res);
    } catch (error) {
      console.log('ERROR:', error);
      continue;
    }

    console.log(await project.balanceOf(addresses[0], tokenIds[0]));
  }
  console.log('GAS:', gasEstimation);
};
export default main;
main.tags = ['DebaseCredits', '8'];

const projects = [
  {
    projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
    holders: [
      {
        accountAddress: '0x7548fd4f2dde80ca245801fab11838834e74fbaf',
        balance: '10',
        decimalBalance: '0.00000000000000001',
        asset: {
          tokenId: '1',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2007',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-17',
        },
      },
      {
        accountAddress: '0xaa45903065057506d76d66dab01318ea5e2cdebd',
        balance: '2054',
        decimalBalance: '0.000000000000002054',
        asset: {
          tokenId: '1',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2007',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-17',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '1',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2007',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-17',
        },
      },
      {
        accountAddress: '0xde202ea7b719bb2f2011cb9547d1c5fd0250334b',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '1',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2007',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-17',
        },
      },
      {
        accountAddress: '0xe8a594c99bde13a2f8248ed0804797c74a1c6df0',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '1',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2007',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-17',
        },
      },
      {
        accountAddress: '0xfcff1c13b9236d4ecd2fdc03dd294e199c2fa03d',
        balance: '2',
        decimalBalance: '0.000000000000000002',
        asset: {
          tokenId: '1',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2007',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-17',
        },
      },
      {
        accountAddress: '0x23a3878fd8e1dc324b7c628e5cb94bd4ecc1fff7',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x2895b2634dc258a2ba66235324b2d70c09785d4c',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x3a15eda03a14729c7478ef0211cf87ab932ed99e',
        balance: '34',
        decimalBalance: '0.000000000000000034',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x512b826b2ed5f536b73bd6e4ccbf517921c818e1',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x71c8da0de3dfd122592ca03216bb3ab9632d0ea7',
        balance: '200',
        decimalBalance: '0.0000000000000002',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x785d61960439f7cdea2311e419223e15ea67a013',
        balance: '20',
        decimalBalance: '0.00000000000000002',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x7d3ba4d7b7bffcc6f1875e8d330371f8020cc7d1',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x9a1e1cd746c51e28a3c206229f448f2412064a8d',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xaa45903065057506d76d66dab01318ea5e2cdebd',
        balance: '9828',
        decimalBalance: '0.000000000000009828',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xb584052b6767a016fd75ac236af0c2050b129c55',
        balance: '23',
        decimalBalance: '0.000000000000000023',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xb8ef9200bac4eafc345fbf83daf9d59d9c05cd95',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xd58d4e362f9fabf5ebaf0787690736f2a25e7f59',
        balance: '500',
        decimalBalance: '0.0000000000000005',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xdd012717477a4db3bebf56cc305ed05ef90af25c',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xdf2226ef8b1fe5b4f75cfd092597248d2823cd33',
        balance: '30',
        decimalBalance: '0.00000000000000003',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xea4224ca5105dd1f9d51a304f123e3136c9ab12b',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0xf2821314b7c7561908d8acbf2ea2db81d4b3407b',
        balance: '65',
        decimalBalance: '0.000000000000000065',
        asset: {
          tokenId: '2',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2008',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-310',
        },
      },
      {
        accountAddress: '0x031d6d22ece4fa615e5dacd9f5d632783558bc8d',
        balance: '515',
        decimalBalance: '0.000000000000000515',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x037ca56f3252a6c7dfb7957a1a15bb830875f94b',
        balance: '4',
        decimalBalance: '0.000000000000000004',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x3a15eda03a14729c7478ef0211cf87ab932ed99e',
        balance: '50',
        decimalBalance: '0.00000000000000005',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x480c25f06166ae277f8b1257e9756c33a43055b7',
        balance: '9480',
        decimalBalance: '0.00000000000000948',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x5b023e603b1734e116394492a3f61939f2600a2c',
        balance: '10',
        decimalBalance: '0.00000000000000001',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x6c91d1b62b1c8a379207d18be6c0c0cfef2c2676',
        balance: '40',
        decimalBalance: '0.00000000000000004',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x7548fd4f2dde80ca245801fab11838834e74fbaf',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x75871335b537fbfa18298e14478d232f1e1a52a8',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x793e87b86f8e739e8520ca003729fc0dce95e7a6',
        balance: '20',
        decimalBalance: '0.00000000000000002',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0xaa45903065057506d76d66dab01318ea5e2cdebd',
        balance: '5425',
        decimalBalance: '0.000000000000005425',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0xd58d4e362f9fabf5ebaf0787690736f2a25e7f59',
        balance: '65',
        decimalBalance: '0.000000000000000065',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0xf14cbd2c08aa6f46a7f6019f79bdcd25a92cffb7',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0xf2821314b7c7561908d8acbf2ea2db81d4b3407b',
        balance: '7',
        decimalBalance: '0.000000000000000007',
        asset: {
          tokenId: '3',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2009',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-60',
        },
      },
      {
        accountAddress: '0x3a15eda03a14729c7478ef0211cf87ab932ed99e',
        balance: '1000',
        decimalBalance: '0.000000000000001',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0x48a045a1f8d42de92a871bd1156a937cf64efcf3',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0x56010d1ca621a0b2aad558449b374e9d37884f70',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0x7c867a64260c20162279e43dace91d6e918ef73f',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0x9c7b45285a44f386eecc0131051495d5ecbdf741',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0xaa45903065057506d76d66dab01318ea5e2cdebd',
        balance: '17317',
        decimalBalance: '0.000000000000017317',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0xe0aa34685b9628eb0ee5158aca3e66a984c8593e',
        balance: '5',
        decimalBalance: '0.000000000000000005',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0xf2821314b7c7561908d8acbf2ea2db81d4b3407b',
        balance: '2',
        decimalBalance: '0.000000000000000002',
        asset: {
          tokenId: '4',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2010',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-453',
        },
      },
      {
        accountAddress: '0x1dcaa6fbbabe8b337446723cb45907f4306cef8c',
        balance: '100',
        decimalBalance: '0.0000000000000001',
        asset: {
          tokenId: '5',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2011',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-2',
        },
      },
      {
        accountAddress: '0x7d621d1c44af16882ce71d0a83cb6fa147aaddfb',
        balance: '0',
        decimalBalance: '0',
        asset: {
          tokenId: '5',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2011',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-2',
        },
      },
      {
        accountAddress: '0xaa45903065057506d76d66dab01318ea5e2cdebd',
        balance: '14898',
        decimalBalance: '0.000000000000014898',
        asset: {
          tokenId: '5',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2011',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-2',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '5860',
        decimalBalance: '0.00000000000000586',
        asset: {
          tokenId: '5',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2011',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '-2',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '22548',
        decimalBalance: '0.000000000000022548',
        asset: {
          tokenId: '8',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2014',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '0',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '26833',
        decimalBalance: '0.000000000000026833',
        asset: {
          tokenId: '9',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2015',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '0',
        },
      },
      {
        accountAddress: '0xcbf5bc0e76e490c432477506f2033587a60b5fac',
        balance: '27563',
        decimalBalance: '0.000000000000027563',
        asset: {
          tokenId: '10',
          decimals: 18,
          serialization: 'ICR-USA-1-448-13-A-0-2016',
          projectAddress: '0x05d59e736cdf4a2ede0b927a9d67dd8775b42a6b',
          type: 'ExPost',
          supply: '0',
        },
      },
    ],
  },
];

// import config before anything else
import { config as dotEnvConfig } from 'dotenv';
dotEnvConfig();
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-deploy';
import '@typechain/hardhat';
import '@nomicfoundation/hardhat-ethers';
import 'hardhat-deploy';
import '@nomicfoundation/hardhat-verify';

const mnemonicPhrase = process.env.MOJO_MNEMONIC;

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.13', // A version or constraint - Ex. "^0.8.13"
    settings: {
      optimizer: {
        enabled: true, // Default: false
        runs: 1, // Default: 200
      },
    },
  },
  networks: {
    hardhat: {
      saveDeployments: true,
      chainId: 31337,
      accounts: {
        mnemonic: mnemonicPhrase,
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 1,
        accountsBalance: '10000000000000000000000',
      },
    },
    arbitrum: {
      chainId: 42161,
      accounts: {
        mnemonic: mnemonicPhrase,
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 1,
      },
      url: `https://arb-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      gasPrice: 'auto',
    },
    polygon: {
      timeout: 60000 * 10, // 10 minutes
      chainId: 137,
      accounts: {
        mnemonic: mnemonicPhrase,
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 1,
      },
      url: `https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      gasPrice: 'auto',
    },
    mumbai: {
      chainId: 80001,
      accounts: {
        mnemonic: mnemonicPhrase,
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 1,
      },
      url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      gasPrice: 'auto',
    },
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLY_SCAN_API_KEY ?? '',
      polygonMumbai: process.env.POLY_SCAN_API_KEY ?? '',
    },
  },
};

export default config;

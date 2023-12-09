require('@nomiclabs/hardhat-truffle5');
require('dotenv').config();

const mnemonicPhrase = process.env.MOJO_MNEMONIC;

module.exports = {
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
    dashboard: {
      url: 'http://localhost:24012',
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
};

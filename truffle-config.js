require('dotenv').config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonicPhrase = process.env.MOJO_MNEMONIC;

module.exports = {
  networks: {
    dashboard: {
			port: 24012,
		},
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 30000000
    },
    arbitrum:{
      network_id: '42161',
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: mnemonicPhrase
        },
        providerOrUrl: `https://arb-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
        numberOfAddresses: 1,
        shareNonce: true,
        derivationPath: "m/44'/60'/0'/0",
        pollingInterval: 8000,
      }),
      disableConfirmationListener: true,
      gasPrice: 100000000,
    },
    polygon: {
      network_id: '137',
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: mnemonicPhrase
        },
        providerOrUrl: `https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
        numberOfAddresses: 1,
        shareNonce: true,
        derivationPath: "m/44'/60'/0'/0",
        pollingInterval: 8000,
      }),
      disableConfirmationListener: true,
      gasPrice: 400000000000,
    },
    mumbai: {
			network_id: '80001',
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: mnemonicPhrase
        },
        providerOrUrl: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
        numberOfAddresses: 1,
        shareNonce: true,
        derivationPath: "m/44'/60'/0'/0",
        pollingInterval: 8000,
      }),

      disableConfirmationListener: true,
		},
  },
  api_keys: {
		polygonscan: process.env.POLY_SCAN_API_KEY,
		arbiscan: process.env.ARBI_SCAN_API_KEY,
	},
  plugins: ['truffle-plugin-verify'],
  compilers: {
    solc: {
      version: "0.8.13", // A version or constraint - Ex. "^0.8.13"
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 1    // Default: 200
        },
      }
    }
  }
};

require('dotenv').config();
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
    polygonMumbai: {
			network_id: '80001',
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
          runs: 200      // Default: 200
        },
      }
    }
  }
};

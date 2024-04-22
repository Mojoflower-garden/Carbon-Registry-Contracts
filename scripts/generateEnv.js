require('dotenv').config();
const nodeVault = require('node-vault');
const fs = require('fs');

var options = {
  apiVersion: 'v1', // default
  endpoint: 'https://vault.mojoflower.io', // default
};

// get new instance of the client
var vault = nodeVault(options);

async function writeToFile(fileData, fileName) {
  const data = Object.entries(fileData)
    .map(([key, value]) => `${key}=${value}`)
    .join('\n');

  await fs.promises.writeFile(fileName, data);
}

// Function to retrieve JSON data from HashiCorp Vault
async function getJsonFromVault() {
  try {
    console.log('Logging in to vault');
    await vault.userpassLogin({
      username: process.env.VAULT_USERNAME,
      password: process.env.VAULT_PASSWORD,
    });
    const environment = process.env.VAULT_ENVIRONMENT ?? 'local';
    const vaultRes = await vault.read(
      `env/data/carbonRegistryContracts/${environment}`
    );
    return vaultRes.data.data;
  } catch (error) {
    console.error(
      'Error retrieving data from HashiCorp Vault:',
      error?.message
    );
    return undefined;
  }
}

// Main function to execute the process
async function generateEnv() {
  try {
    const jsonData = await getJsonFromVault();
    if (!jsonData) return;
    await writeToFile(
      {
        ...jsonData,
        VAULT_PASSWORD: process.env.VAULT_PASSWORD,
        VAULT_USERNAME: process.env.VAULT_USERNAME,
      },
      '.env'
    );
  } catch (error) {
    console.error('Error generating .env file:', error);
  }
}

// Call the main function to start the process
generateEnv();

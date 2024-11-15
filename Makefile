verify-project-mumbai:
	truffle run verify Project@0xc21861fFeFDd68B5827fD26A512607d12A6092e7 --network mumbai
verify-registry-mumbai:
	truffle run verify CarbonContractRegistry@0x1744dd9242a6DD62329Eb72fD68D7168fB838E94 --network mumbai
verify-migrations-mumbai:
	truffle run verify Migrations@0x8DB55bFcbF2ACBB089256ab65e12b83468599b4b --network mumbai
verify-vault-mumbai:
	truffle run verify TokenVault@0xAB6d4fE2A7FE6d87AA46bD151D0196F91E0B8e94 --network mumbai
verify-marketplace-mumbai:
	truffle run verify MarketplaceVault@0x1eA0879512484e270F783E005bE513D7B7453b5f --network mumbai
verify-marketplace-factory-mumbai:
	truffle run verify MarketplaceFactory@0x89e7A478dc7E3654A528061bfccFE16C86f44dDC --network mumbai

verify-project-poly:
	truffle run verify Project@0x186ff692f923a267b0d4792f6c3fbb3206d706d0 --network polygon
verify-registry-poly:
	truffle run verify CarbonContractRegistry@0xC0A9AeDD945444eD036d9FaA71A9557C51383CAe --network polygon
verify-migrations-poly:
	truffle run verify Migrations@0xfd5769788e152B30B12f48614dE5EbeFa814e849 --network polygon
verify-vault-poly:
	truffle run verify TokenVault@0x50B77A5CadFeF29A549FCE71eaC3C794BC6FE5a2 --network polygon
verify-marketplace-poly:
	truffle run verify MarketplaceVault@0x8467ef1dc9565f5638fade17fdecfb27f4515c3d  --network polygon
verify-marketplace-factory-poly:
	truffle run verify MarketplaceFactory@0xb58Ca4BB94C027D49E7305C9C60977019420819F --network polygon

verify-project-arbitrum:
	truffle run verify Project@0xbA4C023aD00dCB4258562A6F8FCae11f5bf508BC --network arbitrum
verify-registry-arbitrum:
	truffle run verify CarbonContractRegistry@0x9f87988FF45E9b58ae30fA1685088460125a7d8A --network arbitrum
verify-migrations-arbitrum:
	truffle run verify Migrations@0xfd5769788e152B30B12f48614dE5EbeFa814e849 --network arbitrum
verify-vault-arbitrum:
	truffle run verify TokenVault@0x6c12adBdc722f6eece125E008A77Dc0a3928d01A --network arbitrum

deploy-base-mumbai:
	npx hardhat deploy --network baseSepolia --tags BASE
verify-hardhat:
	npx hardhat verify --network mainnet DEPLOYED_CONTRACT_ADDRESS "Constructor argument 1"
supported-networks:
	npx hardhat verify --list-networks


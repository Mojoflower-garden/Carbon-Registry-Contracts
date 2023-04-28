verify-project-mumbai:
	truffle run verify Project@0xDa3E8DFeed3434cc56f6b11362212dc0e169510A --network mumbai
verify-registry-mumbai:
	truffle run verify CarbonContractRegistry@0x396B1dD497Ae312d2A3F6bB0a3aB694182605e3F --network mumbai
verify-migrations-mumbai:
	truffle run verify Migrations@0x8DB55bFcbF2ACBB089256ab65e12b83468599b4b --network mumbai
verify-vault-mumbai:
	truffle run verify TokenVault@0xAB6d4fE2A7FE6d87AA46bD151D0196F91E0B8e94 --network mumbai

verify-project-poly:
	truffle run verify Project@0xbA4C023aD00dCB4258562A6F8FCae11f5bf508BC --network polygon
verify-registry-poly:
	truffle run verify CarbonContractRegistry@0x8ecD52AD9E466ab399666237f6b88362Db1bBE20 --network polygon
verify-migrations-poly:
	truffle run verify Migrations@0xfd5769788e152B30B12f48614dE5EbeFa814e849 --network polygon
verify-vault-poly:
	truffle run verify TokenVault@0x50B77A5CadFeF29A549FCE71eaC3C794BC6FE5a2 --network polygon

verify-project-arbitrum:
	truffle run verify Project@0xbA4C023aD00dCB4258562A6F8FCae11f5bf508BC --network arbitrum
verify-registry-arbitrum:
	truffle run verify CarbonContractRegistry@0x9f87988FF45E9b58ae30fA1685088460125a7d8A --network arbitrum
verify-migrations-arbitrum:
	truffle run verify Migrations@0xfd5769788e152B30B12f48614dE5EbeFa814e849 --network arbitrum
verify-vault-arbitrum:
	truffle run verify TokenVault@0x6c12adBdc722f6eece125E008A77Dc0a3928d01A --network arbitrum

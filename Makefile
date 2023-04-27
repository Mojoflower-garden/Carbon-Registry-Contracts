verify-project-mumbai:
	truffle run verify Project@0xDa3E8DFeed3434cc56f6b11362212dc0e169510A --network polygonMumbai
verify-registry-mumbai:
	truffle run verify CarbonContractRegistry@0x396B1dD497Ae312d2A3F6bB0a3aB694182605e3F --network polygonMumbai
verify-migrations-mumbai:
	truffle run verify Migrations@0x8DB55bFcbF2ACBB089256ab65e12b83468599b4b --network polygonMumbai
verify-vault-mumbai:
	truffle run verify TokenVault@0xAB6d4fE2A7FE6d87AA46bD151D0196F91E0B8e94 --network polygonMumbai

verify-project:
	truffle run verify Project@0xbA4C023aD00dCB4258562A6F8FCae11f5bf508BC --network polygon
verify-registry:
	truffle run verify CarbonContractRegistry@0x8ecD52AD9E466ab399666237f6b88362Db1bBE20 --network polygon
verify-migrations:
	truffle run verify Migrations@0xfd5769788e152B30B12f48614dE5EbeFa814e849 --network polygon
verify-vault:
	truffle run verify TokenVault@0x50B77A5CadFeF29A549FCE71eaC3C794BC6FE5a2 --network polygon

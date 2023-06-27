verify-project-mumbai:
	truffle run verify Project@0xCBdc01C56232da1ABa54DFeCB1eb251C42A96b9A --network mumbai
verify-registry-mumbai:
	truffle run verify CarbonContractRegistry@0x1744dd9242a6DD62329Eb72fD68D7168fB838E94 --network mumbai
verify-migrations-mumbai:
	truffle run verify Migrations@0x8DB55bFcbF2ACBB089256ab65e12b83468599b4b --network mumbai
verify-vault-mumbai:
	truffle run verify TokenVault@0xAB6d4fE2A7FE6d87AA46bD151D0196F91E0B8e94 --network mumbai
verify-marketplace-mumbai:
	truffle run verify MarketplaceVault@0x09e007532FD2140AD3f8a38aAEa084d58d100106 --network mumbai
verify-marketplace-factory-mumbai:
	truffle run verify MarketplaceFactory@0xbd5bd90eFc642F19B1398d433c4854cdE947A9cE --network mumbai

verify-project-poly:
	truffle run verify Project@0xb9998d26b61d8cDFfD3fe6d96efB7CA11FCD8065 --network polygon
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

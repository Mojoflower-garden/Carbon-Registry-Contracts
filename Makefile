verify-project:
	truffle run verify Project@0x4A76A0AA9b950c0C323f0E0A8A1E8a0D7a5a5236 --network polygonMumbai
verify-registry:
	truffle run verify CarbonContractRegistry@0x396B1dD497Ae312d2A3F6bB0a3aB694182605e3F --network polygonMumbai
verify-migrations:
	truffle run verify Migrations@0x8DB55bFcbF2ACBB089256ab65e12b83468599b4b --network polygonMumbai
verify-vault:
	truffle run verify TokenVault@0xAB6d4fE2A7FE6d87AA46bD151D0196F91E0B8e94 --network polygonMumbai
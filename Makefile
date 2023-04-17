verify-project:
	truffle run verify Project@0x966e0264Ec03393bA86A5AcFA8d7903433052039 --network polygonMumbai
verify-registry:
	truffle run verify CarbonContractRegistry@0x396B1dD497Ae312d2A3F6bB0a3aB694182605e3F --network polygonMumbai
verify-migrations:
	truffle run verify Migrations@0x8DB55bFcbF2ACBB089256ab65e12b83468599b4b --network polygonMumbai
verify-vault:
	truffle run verify TokenVault@0x1F063c16614813AefBAB49D57e661636Ba74E19B --network polygonMumbai
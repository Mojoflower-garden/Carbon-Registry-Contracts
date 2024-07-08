// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

import './CarbonContractRegistryStorage.sol';
import './interfaces/ICarbonContractRegistry.sol';

contract CarbonContractRegistry is
	Initializable,
	PausableUpgradeable,
	AccessControlUpgradeable,
	UUPSUpgradeable,
	ICarbonContractRegistry,
	CarbonContractRegistryStorage
{
	bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
	bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');

	event VerifiedVaultAddressSet(
		address indexed verifiedVaultAddress,
		address indexed oldVerifiedVaultAddress,
		uint256 indexed id
	);
	event SerializationAddressSet(
		string serialization,
		address indexed serializationProjectContractAddress
	);
	event ProjectFactoryAddressSet(
		address indexed projectFactoryAddress,
		address indexed oldProjectFactoryAddress
	);
	event BeaconSet(
		address indexed beaconAddress,
		address indexed oldBeaconAddress
	);

	event ProjectCreated(
		uint256 indexed projectId,
		address indexed projectAddress,
		string projectName
	);

	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		_disableInitializers();
	}

	function initialize(address beaconAddress) public initializer {
		__Pausable_init();
		__AccessControl_init();
		__UUPSUpgradeable_init();

		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(UPGRADER_ROLE, msg.sender);
		_grantRole(PAUSER_ROLE, msg.sender);

		_projectBeaconAddress = beaconAddress;
	}


	modifier onlyCarbonRegistryProjects() {
		require(
			_addressToProjectIdMapping[msg.sender] != 0 ||
				hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
			'Only CarbonRegistryProject can call this function'
		);
		_;
	}

	function createProject(
		uint256 _projectId,
		string calldata _projectName,
		string calldata _projectMethodology,
		string calldata _projectUri
	) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
		require(_projectId != 0, 'ProjectId cannot be 0');
		require(
			_projectIdToAddressMapping[_projectId] == address(0),
			'ProjectId already exists'
		);

		address projectAddress = _createProject(_projectId, _projectName,_projectMethodology,_projectUri);

		require(
			_addressToProjectIdMapping[projectAddress] == 0,
			'ProjectAddress already exists'
		);
		_projectIdToAddressMapping[_projectId] = projectAddress;
		_addressToProjectIdMapping[projectAddress] = _projectId;
		emit ProjectCreated(_projectId, projectAddress, _projectName);
	}

	function _createProject(
		uint256 _projectId,
		string calldata _projectName,
		string calldata _projectMethodology,
		string calldata _projectUri
	) internal returns (address) {
		/// @dev generate payload for initialize function
		string memory signature = 'initialize(address,address,uint256,string,string,string)';
		bytes memory payload = abi.encodeWithSignature(
			signature,
			address(this),
			msg.sender,
			_projectId,
			_projectName,
			_projectMethodology,
			_projectUri
		);

		address projectAddress = address(
			new BeaconProxy(_projectBeaconAddress, payload)
		);
		return projectAddress;
	}

	// ----------------------------------
	//              SETTERS
	// ----------------------------------

	function registerSerialization(
		string calldata serialization
	) external override whenNotPaused onlyCarbonRegistryProjects {
		require(
			_serializationAddressMapping[serialization] == address(0),
			'Serialization already exists'
		);
		_serializationAddressMapping[serialization] = msg.sender;
		emit SerializationAddressSet(serialization, msg.sender);
	}

	function setBeaconAddress(
		address beaconAddress
	) external override onlyRole(DEFAULT_ADMIN_ROLE) {
		_projectBeaconAddress = beaconAddress;
		emit BeaconSet(beaconAddress, _projectBeaconAddress);
	}


	// ----------------------------------
	//              GETTERS
	// ----------------------------------

	function getVerifiedVaultAddress(uint256 id)
		external
		view
		override
		returns (address)
	{
		return _verifiedVaultMapping[id];
	}

	function getSerializationAddress(
		string calldata serialization
	) external view override returns (address) {
		return _serializationAddressMapping[serialization];
	}

	function getProjectAddressFromId(
		uint256 projectId
	) external view override returns (address) {
		return _projectIdToAddressMapping[projectId];
	}

	function getProjectIdFromAddress(
		address projectAddress
	) external view override returns (uint256) {
		return _addressToProjectIdMapping[projectAddress];
	}

	function getBeaconAddress() external view override returns (address) {
		return _projectBeaconAddress;
	}

	function _authorizeUpgrade(
		address newImplementation
	) internal override onlyRole(UPGRADER_ROLE) {}

	function pause() public onlyRole(PAUSER_ROLE) {
		_pause();
	}

	function unpause() public onlyRole(PAUSER_ROLE) {
		_unpause();
	}

	function testUpgrade() external pure returns(string memory) {
		return "0.0.1";
	}

}

	// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

import './MarketplaceFactoryStorage.sol';

contract MarketplaceFactory is
	Initializable,
	PausableUpgradeable,
	AccessControlUpgradeable,
	UUPSUpgradeable,
	MarketplaceFactoryStorage
{

	bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
	bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');

	event MarketplaceAdded(
		address indexed marketplaceAddress,
		uint256 indexed marketplaceId,
		string marketplaceName
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

		_marketplaceBeaconAddress = beaconAddress;
	}

	function testUpgrade() external pure returns(string memory) {
		return "0.0.1";
	}

    function createMarketplace(string memory _marketplaceName) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) returns(address){
		/// @dev generate payload for initialize function
		string memory signature = 'initialize(address,string)';
		bytes memory payload = abi.encodeWithSignature(
			signature,
			msg.sender,
			_marketplaceName
		);

		address marketplaceAddress = address(
			new BeaconProxy(_marketplaceBeaconAddress, payload)
		);

		unchecked {
			_marketplaceVaultCounter += 1;
		}
		_marketplaceVaultMapping[_marketplaceVaultCounter] = marketplaceAddress;
		emit MarketplaceAdded(
			marketplaceAddress,
			_marketplaceVaultCounter,
			_marketplaceName
		);
		return marketplaceAddress;
	}

	function setBeaconAddress(address _newBeaconAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
		_marketplaceBeaconAddress = _newBeaconAddress;
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

		function getMarketplaceVaultAddress(uint256 id)
		external
		view
		
		returns (address)
	{
		return _marketplaceVaultMapping[id];
	}
	function getBeaconAddress() external view  returns (address) {
		return _marketplaceBeaconAddress;
	}

		function getCurrentMarketplaceCounter() external view  returns (uint) {
		return _marketplaceVaultCounter;
	}

}
    

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract AccessController is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // CARBON REGISTRY
    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
	bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');

    // PROJECTS
    bytes32 public constant URI_SETTER_ROLE = keccak256('URI_SETTER_ROLE');
	bytes32 public constant ANTE_MINTER_ROLE = keccak256('ANTE_MINTER_ROLE');
	bytes32 public constant POST_MINTER_ROLE = keccak256('POST_MINTER_ROLE');
	bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
	bytes32 public constant BLACKLISTED = keccak256('BLACKLISTED');
	bytes32 public constant BLACKLISTER_ROLE = keccak256('BLACKLISTER_ROLE');
	bytes32 public constant BURNER_ROLE = keccak256('BURNER_ROLE');
	bytes32 public constant VERIFIER_ROLE = keccak256('VERIFIER_ROLE');
	bytes32 public constant CLAWBACK_ROLE = keccak256('CLAWBACK_ROLE');
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function grantAdminRole(address[] calldata contracts, address admin) public onlyOwner {
        for (uint i = 0; i < contracts.length; i++) {
            IAccessControlUpgradeable accessControlledContract = IAccessControlUpgradeable(contracts[i]);
            require(accessControlledContract.hasRole(DEFAULT_ADMIN_ROLE, address(this)), "AccessController: must have DEFAULT_ADMIN_ROLE");
            accessControlledContract.grantRole(DEFAULT_ADMIN_ROLE, admin);
        }
    }

    function grantCarbonRegRoles(address carbonContract, address roleHolder) public onlyOwner {
            IAccessControlUpgradeable accessControlledContract = IAccessControlUpgradeable(carbonContract);
            accessControlledContract.grantRole(PAUSER_ROLE, roleHolder);
            accessControlledContract.grantRole(UPGRADER_ROLE, roleHolder);
    }

    function grantProjectRoles(address[] calldata projects, address roleHolder) public onlyOwner {
        for (uint i = 0; i < projects.length; i++) {
            IAccessControlUpgradeable accessControlledContract = IAccessControlUpgradeable(projects[i]);
            accessControlledContract.grantRole(URI_SETTER_ROLE, roleHolder);
            accessControlledContract.grantRole(PAUSER_ROLE, roleHolder);
            accessControlledContract.grantRole(ANTE_MINTER_ROLE, roleHolder);
            accessControlledContract.grantRole(POST_MINTER_ROLE, roleHolder);
            accessControlledContract.grantRole(MINTER_ROLE, roleHolder);
            accessControlledContract.grantRole(UPGRADER_ROLE, roleHolder);
            accessControlledContract.grantRole(BLACKLISTED, roleHolder);
            accessControlledContract.grantRole(BLACKLISTER_ROLE, roleHolder);
            accessControlledContract.grantRole(BURNER_ROLE, roleHolder);
            accessControlledContract.grantRole(VERIFIER_ROLE, roleHolder);
            accessControlledContract.grantRole(CLAWBACK_ROLE, roleHolder);
        }
    }

    function revokeProjectRoles(address[] calldata projects, address roleHolder) public onlyOwner {
        for (uint i = 0; i < projects.length; i++) {
            IAccessControlUpgradeable accessControlledContract = IAccessControlUpgradeable(projects[i]);
            accessControlledContract.revokeRole(URI_SETTER_ROLE, roleHolder);
            accessControlledContract.revokeRole(PAUSER_ROLE, roleHolder);
            accessControlledContract.revokeRole(ANTE_MINTER_ROLE, roleHolder);
            accessControlledContract.revokeRole(POST_MINTER_ROLE, roleHolder);
            accessControlledContract.revokeRole(MINTER_ROLE, roleHolder);
            accessControlledContract.revokeRole(UPGRADER_ROLE, roleHolder);
            accessControlledContract.revokeRole(BLACKLISTED, roleHolder);
            accessControlledContract.revokeRole(BLACKLISTER_ROLE, roleHolder);
            accessControlledContract.revokeRole(BURNER_ROLE, roleHolder);
            accessControlledContract.revokeRole(VERIFIER_ROLE, roleHolder);
            accessControlledContract.revokeRole(CLAWBACK_ROLE, roleHolder);
            accessControlledContract.revokeRole(DEFAULT_ADMIN_ROLE, roleHolder);
        }
    }

    function revokeCarbonRegRoles(address carbonRegContract, address roleHolder) public onlyOwner {
        IAccessControlUpgradeable accessControlledContract = IAccessControlUpgradeable(carbonRegContract);
        accessControlledContract.revokeRole(PAUSER_ROLE, roleHolder);
        accessControlledContract.revokeRole(UPGRADER_ROLE, roleHolder);
        accessControlledContract.revokeRole(DEFAULT_ADMIN_ROLE, roleHolder);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
	

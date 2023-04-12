// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "./CarbonContractRegistryStorage.sol";
import "./interfaces/ICarbonContractRegistry.sol";

contract CarbonContractRegistry is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ICarbonContractRegistry,
    CarbonContractRegistryStorage
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event NonVerifiedVaultAddressSet(
        address indexed nonVerifiedVaultAddress,
        address indexed oldNonVerifiedVaultAddress
    );
    event VerifiedVaultAddressSet(
        address indexed verifiedVaultAddress,
        address indexed oldVerifiedVaultAddress
    );
    event SerializationAddressSet(
        string indexed serialization,
        address indexed serializationProjectContractAddress
    );
    event ProjectIdAddressSet(
        uint256 indexed projectId,
        address indexed projectAddress
    );
    event ProjectFactoryAddressSet(
        address indexed projectFactoryAddress,
        address indexed oldProjectFactoryAddress
    );
    event BeaconSet(
        address indexed beaconAddress,
        address indexed oldBeaconAddress
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

        _beaconAddress = beaconAddress;
    }

    modifier onlyCarbonRegistryProjects() {
        require(
            _addressToProjectIdMapping[msg.sender] != 0 ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Only CarbonRegistryProject can call this function"
        );
        _;
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

    // ----------------------------------
    //              SETTERS
    // ----------------------------------

    function setNonVerifiedVaultAddress(
        address nonVerifiedVaultAddress
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        emit NonVerifiedVaultAddressSet(
            nonVerifiedVaultAddress,
            _nonVerifiedVaultAddress
        );
        _nonVerifiedVaultAddress = nonVerifiedVaultAddress;
    }

    function setVerifiedVaultAddress(
        address verifiedVaultAddress
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        emit VerifiedVaultAddressSet(
            verifiedVaultAddress,
            _verifiedVaultAddress
        );
        _verifiedVaultAddress = verifiedVaultAddress;
    }

    function registerSerialization(
        string calldata serialization
    ) external override whenNotPaused onlyCarbonRegistryProjects {
        require(
            _serializationAddressMapping[serialization] == address(0),
            "Serialization already exists"
        );
        _serializationAddressMapping[serialization] = msg.sender;
        emit SerializationAddressSet(serialization, msg.sender);
    }

    function createProject(
        uint256 _projectId,
        string calldata _projectName
    ) external override whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_projectId != 0, "ProjectId cannot be 0");
        require(
            _projectIdToAddressMapping[_projectId] == address(0),
            "ProjectId already exists"
        );

        require(
            _addressToProjectIdMapping[projectAddress] == 0,
            "ProjectAddress already exists"
        );
        _projectIdToAddressMapping[projectId] = projectAddress;
        _addressToProjectIdMapping[projectAddress] = projectId;
        emit ProjectIdAddressSet(projectId, projectAddress);
    }

    function _createProject(
        uint256 _projectId,
        string calldata _projectName
    ) internal returns (address) {
        /// @dev generate payload for initialize function
        string memory signature = "initialize(address,uint256,string)";
        bytes memory payload = abi.encodeWithSignature(
            signature,
            owner(),
            _projectId,
            _projectName
        );

        address projectAddress = address(
            new BeaconProxy(_beaconAddress, payload)
        );
        emit ProjectCreated(projectAddress, _projectId, _projectName);
        return projectAddress;
    }

    function setProjectFactoryAddress(
        address projectFactoryAddress
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(PROJECT_FACTORY_ROLE, _projectFactoryAddress);
        _projectFactoryAddress = projectFactoryAddress;
        _grantRole(PROJECT_FACTORY_ROLE, _projectFactoryAddress);
        emit ProjectFactoryAddressSet(
            _projectFactoryAddress,
            projectFactoryAddress
        );
    }

    function setBeaconAddress(
        address beaconAddress
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _beaconAddress = beaconAddress;
        emit BeaconSet(beaconAddress, _beaconAddress);
    }

    // ----------------------------------
    //              GETTERS
    // ----------------------------------

    function getNonVerifiedVaultAddress()
        external
        view
        override
        returns (address)
    {
        return _nonVerifiedVaultAddress;
    }

    function getVerifiedVaultAddress()
        external
        view
        override
        returns (address)
    {
        return _verifiedVaultAddress;
    }

    function getSerializationAddress(
        string calldata serialization
    ) external view override returns (address) {
        return _serializationAddressMapping[serialization];
    }

    function checkSerializationAddress(
        string calldata serialization
    ) external view override returns (bool) {
        return _serializationAddressMapping[serialization] != address(0);
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

    function getProjectFactoryAddress()
        external
        view
        override
        returns (address)
    {
        return _projectFactoryAddress;
    }

    function getBeaconAddress() external view override returns (address) {
        return _beaconAddress;
    }
}

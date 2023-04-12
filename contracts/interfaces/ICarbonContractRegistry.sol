// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

interface ICarbonContractRegistry {
    // ----------------------------------
    //              SETTERS
    // ----------------------------------

    function setNonVerifiedVaultAddress(
        address nonVerifiedVaultAddress
    ) external;

    function setVerifiedVaultAddress(address verifiedVaultAddress) external;

    function registerSerialization(string calldata serialization) external;

    function setProjectIdAddress(
        uint256 projectId,
        address projectAddress
    ) external;

    function setProjectFactoryAddress(address projectFactoryAddress) external;

    function setBeaconAddress(address beaconAddress) external;

    // ----------------------------------
    //              GETTERS
    // ----------------------------------

    function getNonVerifiedVaultAddress() external view returns (address);

    function getVerifiedVaultAddress() external view returns (address);

    function getSerializationAddress(
        string calldata serialization
    ) external view returns (address);

    function checkSerializationAddress(
        string calldata serialization
    ) external view returns (bool);

    function getProjectAddressFromId(
        uint256 projectId
    ) external view returns (address);

    function getProjectIdFromAddress(
        address projectAddress
    ) external view returns (uint256);

    function getProjectFactoryAddress() external view returns (address);

    function getBeaconAddress() external view returns (address);
}

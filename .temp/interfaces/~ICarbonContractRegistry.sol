// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ICarbonContractRegistry {
    // ----------------------------------
    //              SETTERS
    // ----------------------------------

    function createNewVerifiedVault() external;

    function registerSerialization(string calldata serialization) external;

    function setBeaconAddress(address beaconAddress) external;

    function setTokenVaultBeaconAddress(address tokenVaultBeaconAddress) external;

    // ----------------------------------
    //              GETTERS
    // ----------------------------------

    function getTokenVaultBeaconAddress() external view returns (address);

    function getVerifiedVaultAddress(uint256 id) external view returns (address);

    function getSerializationAddress(
        string calldata serialization
    ) external view returns (address);

    function getProjectAddressFromId(
        uint256 projectId
    ) external view returns (address);

    function getProjectIdFromAddress(
        address projectAddress
    ) external view returns (uint256);

    function getBeaconAddress() external view returns (address);
}

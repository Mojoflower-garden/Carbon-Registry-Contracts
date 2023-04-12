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

    function setBeaconAddress(address beaconAddress) external;

    // ----------------------------------
    //              GETTERS
    // ----------------------------------

    function getNonVerifiedVaultAddress() external view returns (address);

    function getVerifiedVaultAddress() external view returns (address);

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

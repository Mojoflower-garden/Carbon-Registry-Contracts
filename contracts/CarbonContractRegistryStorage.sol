// SPDX-FileCopyrightText: 2023 Mojoflower
//
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

/// @dev  CarbonContractRegistryStorage is used for separation of data and logic
abstract contract CarbonContractRegistryStorageV1 {
    address internal _verifiedVaultAddress;
    address internal _projectBeaconAddress;

    mapping(string => address) internal _serializationAddressMapping;
    mapping(uint256 => address) internal _projectIdToAddressMapping;
    mapping(address => uint256) internal _addressToProjectIdMapping;
}

abstract contract CarbonContractRegistryStorageV2 {
    uint256 internal _verifiedVaultCounter;
    address internal _tokenVaultBeaconAddress; // Not used anymore - but needs to stay because of storage system in the evm
    mapping(uint256 => address) internal _verifiedVaultMapping;
}

abstract contract CarbonContractRegistryStorage is
    CarbonContractRegistryStorageV1,
    CarbonContractRegistryStorageV2
{
        /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[42] private __gap;
}

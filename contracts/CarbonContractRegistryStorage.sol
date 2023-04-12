// SPDX-FileCopyrightText: 2023 Mojoflower
//
// SPDX-License-Identifier: UNLICENSED

// If you encounter a vulnerability or an issue, please contact <security@mojoflower.io> or visit security.mojoflower.io
pragma solidity 0.8.14;

/// @dev  CarbonContractRegistryStorage is used for separation of data and logic
abstract contract CarbonContractRegistryStorageV1 {
    address internal _nonVerifiedVaultAddress;
    address internal _verifiedVaultAddress;
    address internal _projectFactoryAddress;
    address internal _beaconAddress;

    mapping(string => address) internal _serializationAddressMapping;
    mapping(uint256 => address) internal _projectIdToAddressMapping;
    mapping(address => uint256) internal _addressToProjectIdMapping;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[43] private __gap;
}

abstract contract CarbonContractRegistryStorage is
    CarbonContractRegistryStorageV1
{}

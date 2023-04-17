// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


abstract contract TokenVaultStorageV1 {
    // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[50] private __gap;
}

abstract contract TokenVaultStorage is TokenVaultStorageV1 {}

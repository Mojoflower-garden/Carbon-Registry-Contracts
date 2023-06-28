// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


abstract contract MarketplaceVaultStorageV1 {

    string public name;
}


abstract contract MarketplaceVaultStorageV2 {
    // Mapping from token address to account balances
    mapping(address => mapping(uint256 => mapping(address => uint256))) public balances;
    
}

abstract contract MarketplaceVaultStorage is MarketplaceVaultStorageV1,MarketplaceVaultStorageV2 {
        // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[48] private __gap;
}

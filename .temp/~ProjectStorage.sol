// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "/Users/thorduragustsson/Programming/Projects/CarbonRegistryContracts/node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./types/~ProjectTypes.sol";
import "/Users/thorduragustsson/Programming/Projects/CarbonRegistryContracts/node_modules/@openzeppelin/contracts/utils/Counters.sol";

abstract contract ProjectStorageV1 is Initializable {
    uint256 public topTokenId; 
    uint256 public projectId;
    uint8 public maxAntePercentage; // Deprecated - but has to stay here because of immutability of storage space.
    string public projectName; 
    address public contractRegistry;
    mapping(uint256 => VintageData) public exPostVintageMapping;
    mapping(uint256 => uint256) public exAnteToExPostTokenId;
    mapping(uint256 => uint256) public exPostToExAnteTokenId;
    mapping(string => uint256) public serializationToExPostTokenIdMapping;
    mapping(uint256 => RetirementData) public retirementMapping;
}

abstract contract ProjectStorageV2 {
    string public projectUri;
    string public methodology; // The id of the methodology
}

abstract contract ProjectStorage is ProjectStorageV1, ProjectStorageV2 {

    function __ProjectStorage_init(
        address _contractRegistry,
        uint256 _projectId,
        string memory _projectName,
        string memory _projectUri,
        string memory _methodology
    ) public initializer {
        contractRegistry = _contractRegistry;
        projectName = _projectName;
        projectId = _projectId;
        projectUri = _projectUri;
        methodology = _methodology;
    }
        // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[38] private __gap;
}

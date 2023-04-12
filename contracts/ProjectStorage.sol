// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./types/ProjectTypes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract ProjectStorageV1 is Initializable {
    uint256 internal tokenId;
    uint256 public projectId;
    string public projectName;
    uint8 public maxAntePercentage;
    address public contractRegistry;
    mapping(uint256 => VintageData) public exPostVintageMapping;
    mapping(uint256 => uint256) public exAnteToExPostTokenId;
    mapping(uint256 => uint256) public exPostToExAnteTokenId;
    mapping(string => uint256) public serializationToExPostTokenIdMapping;
    mapping(uint256 => RetirementData) public retirementMapping;

    function __ProjectStorage_init(
        address _contractRegistry,
        uint8 _maxAntePerc,
        uint256 _projectId,
        string memory _projectName
    ) public initializer {
        maxAntePercentage = _maxAntePerc;
        projectId = _projectId;
        projectName = _projectName;
        contractRegistry = _contractRegistry;
    }

    // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[40] private __gap;
}

abstract contract ProjectStorage is ProjectStorageV1 {}

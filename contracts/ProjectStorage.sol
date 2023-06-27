// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./types/ProjectTypes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract ProjectStorageV1 is Initializable {
    uint256 public topTokenId; 
    uint256 public projectId; // has been removed, but must stay here because of storage layout
    uint8 public maxAntePercentage;
    string public projectName; // has been removed, but must stay here because of storage layout
    address public contractRegistry;
    mapping(uint256 => VintageData) public exPostVintageMapping;
    mapping(uint256 => uint256) public exAnteToExPostTokenId;
    mapping(uint256 => uint256) public exPostToExAnteTokenId;
    mapping(string => uint256) public serializationToExPostTokenIdMapping;
    mapping(uint256 => RetirementData) public retirementMapping;
}

abstract contract ProjectStorageV2 {
    ProjectData public projectInfo;
}

abstract contract ProjectStorage is ProjectStorageV1, ProjectStorageV2 {

    function __ProjectStorage_init(
        address _contractRegistry,
        uint8 _maxAntePerc,
        uint256 _projectId,
        string memory _projectName,
        string memory projectUri,
        string memory methodology
    ) public initializer {
        maxAntePercentage = _maxAntePerc;
        contractRegistry = _contractRegistry;

        projectInfo = ProjectData(
            _projectName,
            _projectId,
            projectUri,
            methodology
        );
    }
        // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[39] private __gap;
}

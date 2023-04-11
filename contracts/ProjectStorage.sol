// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

enum TokenType {
    NotSet, // 0
    ExPost, // 1
    ExAnte, // 2
    RetirementNft // 3
}

struct VintageData {
    string serialization;
    bool verified;
    TokenType tokenType;
}

struct RetirementData {
    address retireeAddress;
    uint256 amount;
    uint256 vintageTokenId;
    string retiree;
    string customUri;
    string comment;
}

abstract contract ProjectStorageV1 is Initializable {
    string public projectId;
    uint8 public maxAntePercentage;
    mapping(uint256 => VintageData) public vintageMapping;
    mapping(string => uint256) public serializationToTokenIdMapping;
    mapping(uint256 => uint256) public exPostToExAnteToken;
    mapping(uint256 => bool) public isTokenMintable;
    mapping(uint256 => bool) public isTokenClawbackEnabled;
    mapping(uint256 => RetirementData) public retirementMapping;

    function __ProjectStorage_init(uint8 _maxAntePerc) public initializer {
        maxAntePercentage = _maxAntePerc;
    }

    // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[42] private __gap;
}

abstract contract ProjectStorage is ProjectStorageV1 {}

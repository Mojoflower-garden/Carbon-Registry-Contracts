// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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

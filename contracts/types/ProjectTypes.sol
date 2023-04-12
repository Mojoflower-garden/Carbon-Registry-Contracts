// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

enum AdminActionReason {
    NoReason,
    OverEstimated,
    UnderEstimated,
    CreditsLost,
    CreditsGained
}

abstract contract ProjectTypes {}

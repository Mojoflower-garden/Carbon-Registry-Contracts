// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct VintageData {
    string serialization;
    uint256 estMitigations; // in TC02e
    uint256 verificationPeriodStart; // timestamp seconds since Unix
    uint256 verificationPeriodEnd;
    uint256 lastVerificationTimestamp;
}

struct RetirementData {
    address retiree;
    uint256 amount;
    uint256 vintageTokenId;
    string retireeName;
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

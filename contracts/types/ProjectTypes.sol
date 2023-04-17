// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct VintageData {
    string serialization;
    uint256 estMitigations;
    uint256 verificationPeriodStart; // timestamp seconds since Unix
    uint256 verificationPeriodEnd;
    uint256 lastVerificationTimestamp;
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

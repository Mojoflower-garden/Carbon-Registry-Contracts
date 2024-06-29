// SPDX-FileCopyrightText: 2023 Mojoflower
//
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct signatureBatchTransferPayload {
    uint256 deadline;
    string description;
    address signer;
    address to;
    uint256[] tokenIds;
    uint256[] amounts;
    uint256 nonce;
}

abstract contract CustomSignaturesTypes {}

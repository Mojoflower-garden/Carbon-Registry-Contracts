// SPDX-FileCopyrightText: 2023 Mojoflower
//
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct signatureTransferPayload {
    uint256 deadline;
    string description;
    address signer;
    address to;
    uint256 tokenId;
    uint256 amount;
    uint256 nonce;
}

struct signatureGenericPayload {
    uint256 deadline;
    string description;
    address signer;
    uint256 nonce;
}

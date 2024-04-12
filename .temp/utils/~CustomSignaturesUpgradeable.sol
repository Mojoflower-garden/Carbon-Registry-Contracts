// SPDX-FileCopyrightText: 2023 Mojoflower
//
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "/Users/thorduragustsson/Programming/Projects/CarbonRegistryContracts/node_modules/@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "/Users/thorduragustsson/Programming/Projects/CarbonRegistryContracts/node_modules/@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "./~CustomSignaturesTypes.sol";

contract CustomSignaturesUpgradeable is EIP712Upgradeable {
    mapping(address => uint32) public signatureNonces;
    event TransferSignatureValid(bytes signature, signatureTransferPayload payload);

    function __CustomSignatures_init(
        string memory signatureName,
        string memory version
    ) internal onlyInitializing {
        __EIP712_init(signatureName, version);
    }

    modifier onlyValidSignatureTransfer(
        bytes calldata signature,
        signatureTransferPayload calldata payload
    ) {
        emit TransferSignatureValid(signature, payload);
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "signatureTransferPayload(uint256 deadline,string description,address signer,address to,uint256 tokenId,uint256 amount,uint256 nonce)"
                    ),
                    payload.deadline,
                    keccak256(abi.encodePacked(payload.description)), // https://ethereum.stackexchange.com/questions/131282/ethers-eip712-wont-work-with-strings
                    payload.signer,
                    payload.to,
                    payload.tokenId,
                    payload.amount,
                    signatureNonces[payload.signer]
                )
            )
        );
        checkBaseSignature(digest, signature, payload.signer, payload.deadline);
        signatureNonces[payload.signer]++;
        _;
    }

    function checkBaseSignature(
        bytes32 digest,
        bytes memory signature,
        address payloadSigner,
        uint256 payloadDeadline
    ) internal view returns (address signer) {
        signer = ECDSAUpgradeable.recover(digest, signature);
        require(signer == payloadSigner && signer != address(0), "Invalid signature");
        require(block.timestamp < payloadDeadline, "Signature expired");
    }

    // /**
    //  * @dev This empty reserved space is put in place to allow future versions to add new
    //  * variables without shifting down storage in the inheritance chain.
    //  * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    //  */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Importing the IERC1155Upgradeable interface from OpenZeppelin
import "./interfaces/IProject.sol";
import "./utils/CustomSignaturesTypes.sol";
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

struct SignatureBatchTransferPayload {
    address contractAddress;
    signatureBatchTransferPayload payload;
    bytes signature;
}

struct SignatureBatchRetirementPayload {
    address contractAddress;
    signatureBatchTransferPayload payload;
    bytes signature;
}

contract BatchCreditActions is
	Initializable,
	PausableUpgradeable,
	AccessControlUpgradeable,
	UUPSUpgradeable {
    
    bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');

    /// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		_disableInitializers();
	}

    function initialize() public initializer {
		__Pausable_init();
		__AccessControl_init();
		__UUPSUpgradeable_init();

		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(UPGRADER_ROLE, msg.sender);
	}

function handleTransfers(
    SignatureBatchTransferPayload[] calldata transferItems,
    bytes calldata transferData
) public {
    for (uint256 i = 0; i < transferItems.length; i++) {
        IProject erc1155 = IProject(transferItems[i].contractAddress);
        erc1155.batchTransferFromSignature(
            transferItems[i].signature,
            transferItems[i].payload,
            transferData
        );
    }
}

function handleRetirements(
    SignatureBatchRetirementPayload[] calldata retirementItems,
    string memory retireeName,
    string memory customUri,
    string memory comment,
    bytes calldata retirementData
) public {
    for (uint256 i = 0; i < retirementItems.length; i++) {
        IProject project = IProject(retirementItems[i].contractAddress);
        project.retireFromSignature(
            retirementItems[i].signature,
            retirementItems[i].payload,
            retireeName,
            customUri,
            comment,
            retirementData
        );
    }
}

function batchTransferOrRetire(
    SignatureBatchTransferPayload[] calldata transferItems,
    SignatureBatchRetirementPayload[] calldata retirementItems,
    string memory retireeName,
    string memory customUri,
    string memory comment,
    bytes calldata transferData,
    bytes calldata retirementData
) public {
    handleTransfers(transferItems, transferData);
    handleRetirements(retirementItems, retireeName, customUri, comment, retirementData);
}


    function _authorizeUpgrade(
	address newImplementation
	) internal override onlyRole(UPGRADER_ROLE) {}
}

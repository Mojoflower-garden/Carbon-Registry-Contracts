// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";


import './ProjectStorage.sol';
import './interfaces/ICarbonContractRegistry.sol';
import './utils/CustomSignaturesUpgradeable.sol';
import './interfaces/IProject.sol';

contract Project is
	IProject,
	Initializable,
	ERC1155Upgradeable,
	AccessControlUpgradeable,
	PausableUpgradeable,
	ERC1155SupplyUpgradeable,
	UUPSUpgradeable,
	CustomSignaturesUpgradeable,
	ProjectStorage,
	ERC1155HolderUpgradeable
{
	bytes32 public constant URI_SETTER_ROLE = keccak256('URI_SETTER_ROLE');
	bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
	bytes32 public constant ANTE_MINTER_ROLE = keccak256('ANTE_MINTER_ROLE');
	bytes32 public constant POST_MINTER_ROLE = keccak256('POST_MINTER_ROLE');
	bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
	bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');
	bytes32 public constant BLACKLISTED = keccak256('BLACKLISTED');
	bytes32 public constant BLACKLISTER_ROLE = keccak256('BLACKLISTER_ROLE');
	bytes32 public constant BURNER_ROLE = keccak256('BURNER_ROLE');
	bytes32 public constant VERIFIER_ROLE = keccak256('VERIFIER_ROLE');
	bytes32 public constant CLAWBACK_ROLE = keccak256('CLAWBACK_ROLE');


/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		_disableInitializers();
	}

	function initialize(
		address _contractRegistry,
		address _owner,
		uint256 _projectId,
		string memory _projectName,
		string memory _projectMethodology,
		string memory _projectUri
	) public initializer {
		__ERC1155_init('');
		__AccessControl_init();
		__Pausable_init();
		__ERC1155Supply_init();
		__UUPSUpgradeable_init();
		__CustomSignatures_init("Carbon Registry", '0.0.1');

		// Our Inits
		__ProjectStorage_init(_contractRegistry, _projectId, _projectName, _projectUri, _projectMethodology);

		_grantRole(DEFAULT_ADMIN_ROLE, _owner);
		_grantRole(URI_SETTER_ROLE, _owner);
		_grantRole(PAUSER_ROLE, _owner);
		_grantRole(ANTE_MINTER_ROLE, _owner);
		_grantRole(POST_MINTER_ROLE, _owner);
		_grantRole(UPGRADER_ROLE, _owner);
		_grantRole(BLACKLISTER_ROLE, _owner);
		_grantRole(VERIFIER_ROLE, _owner);
		_grantRole(CLAWBACK_ROLE, _owner);

		_grantRole(POST_MINTER_ROLE, msg.sender); // Just so projectFactory can mint exPost on creation of the project
	}

	modifier notBlacklisted(address account) {
		require(
			!hasRole(BLACKLISTED, account),
		"0"
		);
		_;
	}

	modifier onlyExPostTokens(uint256[] memory tokenIds) {
		for (uint256 i = 0; i < tokenIds.length; i++) {
			require(isExPostToken(tokenIds[i]), "1");
		}
		_;
	}

	modifier onlyExPostToken(uint256 tokenId) {
		require(isExPostToken(tokenId), "1");
		_;
	}

	modifier onlyVerifiedStatus(bool isVerified, uint256 tokenId) {
		require(
			(exPostVintageMapping[tokenId].lastVerificationTimestamp >=
				exPostVintageMapping[tokenId].verificationPeriodEnd) ==
				isVerified,
			isVerified
				? "2"
				: "3"
		);
		_;
	}

	function isExPostToken(uint256 tokenId) public view returns (bool) {
		return bytes(exPostVintageMapping[tokenId].serialization).length > 0;
	}

	function testUpgrade() external pure returns(string memory) {
		return "0.0.6";
	}

	// ----------------------------------
	//         Minting Functions
	// ----------------------------------

	function createExPostVintage(
		uint256 estAmount,
		uint256 verificationPeriodStart,
		uint256 verificationPeriodEnd,
		string memory serialization
	) public onlyRole(POST_MINTER_ROLE) {
		
		require(
			verificationPeriodEnd > verificationPeriodStart,
			"4"
		);
		uint256 newTokenId = nextTokenId();
		ICarbonContractRegistry(contractRegistry).registerSerialization(
			serialization
		);
		serializationToExPostTokenIdMapping[serialization] = newTokenId;
		exPostVintageMapping[newTokenId] = VintageData(
			serialization,
			estAmount,
			verificationPeriodStart,
			verificationPeriodEnd,
			0
		);
		emit ExPostCreated(
			newTokenId,
			estAmount,
			verificationPeriodStart,
			verificationPeriodEnd,
			serialization
		);
	}

	function createExPostVintageBatch(
		VintageData[] memory vintages
	) public onlyRole(POST_MINTER_ROLE) {
		for (uint256 i = 0; i < vintages.length; i++) {
			createExPostVintage(
				vintages[i].estMitigations,
				vintages[i].verificationPeriodStart,
				vintages[i].verificationPeriodEnd,
				vintages[i].serialization
			);
		}
	}

	function mintExAnte(
		address account,
		uint256 exPostTokenId,
		uint256 amount,
		bytes memory data
	)
		public
		onlyRole(ANTE_MINTER_ROLE)
		onlyExPostToken(exPostTokenId)
		onlyVerifiedStatus(false, exPostTokenId)
	{
		uint256 exAnteTokenId = exPostToExAnteTokenId[exPostTokenId];
		if (exAnteTokenId == 0) {
			exAnteTokenId = nextTokenId();
			exPostToExAnteTokenId[exPostTokenId] = exAnteTokenId;
			exAnteToExPostTokenId[exAnteTokenId] = exPostTokenId;
		}
		emit ExAnteMinted(exAnteTokenId, exPostTokenId, account,  amount);
		_mint(account, exAnteTokenId, amount, data);
	}

	function changeVintageMitigationEstimate(
		uint256 tokenId,
		uint256 newEstAmount,
		AdminActionReason reason
	)
		public
		onlyRole(DEFAULT_ADMIN_ROLE)
		onlyExPostToken(tokenId)
		onlyVerifiedStatus(false, tokenId)
	{
		emit VintageMitigationEstimateChanged(
			tokenId,
			newEstAmount,
			exPostVintageMapping[tokenId].estMitigations,
			reason
		);
		exPostVintageMapping[tokenId].estMitigations = newEstAmount;
	}

	function verifyAndMintExPost(
		address verificationVault,
		uint256 tokenId,
		uint256 amountVerified,
		uint256 amountToAnteHolders,
		uint256 verificationPeriodStart,
		uint256 verificationPeriodEnd,
		string memory monitoringReport
	)
		public
		onlyRole(VERIFIER_ROLE)
		onlyExPostToken(tokenId)
		onlyVerifiedStatus(false, tokenId)
	{
		require(
			amountVerified >= amountToAnteHolders,
			"6"
		);

		uint256 exAnteTokenId = exPostToExAnteTokenId[tokenId];
		if (exAnteTokenId == 0) {
			// If exAnteTokenId is zero then there are no ante holders
			require(amountToAnteHolders == 0, "9");
		}

		emit ExPostVerifiedAndMinted(
			tokenId,
			amountVerified,
			amountToAnteHolders,
			verificationPeriodStart,
			verificationPeriodEnd,
			monitoringReport
		);

		if (amountVerified - amountToAnteHolders > 0) {
			// Mint To Verification Vault
			_mint(
				verificationVault,
				tokenId,
				amountVerified - amountToAnteHolders,
				''
			);
		}
		exPostVintageMapping[tokenId]
			.lastVerificationTimestamp = verificationPeriodEnd;

		if (amountToAnteHolders > 0) {
			// Mint to this address, where ante holders will claim
			_mint(address(this), tokenId, amountToAnteHolders, '');
		}
	}

	function adminClawback(
		address from,
		address to,
		uint256 tokenId,
		uint256 amount,
		AdminActionReason reason
	) public onlyRole(CLAWBACK_ROLE) {
		emit AdminClawback(from, to, tokenId, amount, reason);
		_safeTransferFrom(from, to, tokenId, amount, '');
	}

	function exchangeAnteForPostEvenSteven(
		address[] memory accounts,
		uint256 exPostTokenId,
		bytes memory data
	)
		external
		onlyExPostToken(exPostTokenId)
	{
		uint256 exAnteTokenId = exPostToExAnteTokenId[exPostTokenId];
		require(exAnteTokenId != 0, "9");
		uint256 currentExAnteSupply = totalSupply(exAnteTokenId);
		uint256 currentExPostSupplyInContract = balanceOf(
			address(this),
			exPostTokenId
		);
		require(currentExPostSupplyInContract > 0, "10");

		for (uint256 i = 0; i < accounts.length; i++) {
			
			uint256 amountExAnte = balanceOf(accounts[i], exAnteTokenId);
			uint256 amountExPost = (amountExAnte *
				currentExPostSupplyInContract) / currentExAnteSupply;
			uint256 exAnteBurnAmount = amountExAnte;
			if (amountExAnte > amountExPost) {
				exAnteBurnAmount = amountExPost;
			}
						emit ExchangeAnteForPost(
				accounts[i],
				exPostTokenId,
				amountExPost,
				exAnteBurnAmount
			);
			_burn(accounts[i], exAnteTokenId, exAnteBurnAmount);
			_safeTransferFrom(
				address(this),
				accounts[i],
				exPostTokenId,
				amountExPost,
				data
			);
		}
	}

	// ----------------------------------
	//              Actions
	// ----------------------------------


	function transferFromSignature(
		bytes calldata signature,
		signatureTransferPayload calldata payload,
		bytes memory data
	) public payable onlyValidSignatureTransfer(signature, payload) {
		_safeTransferFrom(
			payload.signer,
			payload.to,
			payload.tokenId,
			payload.amount,
			data
		);
	}

	function burnFromAccount(
		address account,
		uint256 tokenId,
		uint256 amount
	) public onlyRole(CLAWBACK_ROLE) {
		_burn(account, tokenId, amount);
	}

	function retire(
		uint256 tokenId,
		uint256 amount,
		address beneficiary,
		string memory retireeName,
		string memory customUri,
		string memory comment,
		bytes memory data
	) public onlyExPostToken(tokenId) returns (uint256 nftTokenId) {
		if(msg.sender == beneficiary){
			return _retire(
				msg.sender,
				tokenId,
				amount,
				retireeName,
				customUri,
				comment,
				data
			);
		}

		require(beneficiary != address(0));
		_safeTransferFrom(msg.sender, beneficiary, tokenId, amount, data);
		return _retire(
			beneficiary,
			tokenId,
			amount,
			retireeName,
			customUri,
			comment,
			data
		);
	}

	function retireFromSignature(
		bytes calldata signature,
		signatureTransferPayload calldata payload,
		string memory retireeName,
		string memory customUri,
		string memory comment,
		bytes memory data
	)
		public
		onlyExPostToken(payload.tokenId)
		onlyValidSignatureTransfer(signature, payload)
		returns (uint256 nftTokenId)
	{
		if(payload.signer == payload.to){
			return _retire(
				payload.signer,
				payload.tokenId,
				payload.amount,
				retireeName,
				customUri,
				comment,
				data
			);
		}
		require(payload.to != address(0));
		_safeTransferFrom(payload.signer, payload.to, payload.tokenId, payload.amount, data);
		return _retire(
			payload.to,
			payload.tokenId,
			payload.amount,
			retireeName,
			customUri,
			comment,
			data
		);
	}

	function _retire(
		address retiree,
		uint256 tokenId,
		uint256 amount,
		string memory retireeName,
		string memory customUri,
		string memory comment,
		bytes memory data
	) internal returns(uint256 nftTokenId) {
		_burn(retiree, tokenId, amount);
		nftTokenId = mintRetirementCertificate(retiree, tokenId, amount, retireeName, customUri, comment);
		emit RetiredVintage(retiree, tokenId, amount, nftTokenId, data);
	}

	function mintRetirementCertificate(
		address account,
		uint256 tokenId,
		uint256 amount,
		string memory retireeName,
		string memory customUri,
		string memory comment
	) internal returns (uint256) {
		uint256 nftTokenId = nextTokenId();
		retirementMapping[nftTokenId] = RetirementData(
			account,
			amount,
			tokenId,
			retireeName,
			customUri,
			comment
		);
		_mint(account, nftTokenId, 1, '');
		return nftTokenId;
	}


	function cancelCreditsFromSignature(
		bytes calldata signature,
		signatureTransferPayload calldata payload,
		string memory comment,
		bytes memory data
	)
		public
		onlyValidSignatureTransfer(signature, payload)
	{
		emit CancelledCredits(payload.signer, payload.tokenId, payload.amount,comment, data);
		_burn(payload.signer, payload.tokenId, payload.amount);
	}

	// ----------------------------------
	//              Hooks
	// ----------------------------------

	function _beforeTokenTransfer(
		address operator,
		address from,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	)
		internal
		override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
		whenNotPaused
		notBlacklisted(from)
		notBlacklisted(to)
	{
		for(uint256 i = 0; i < ids.length; i++) {
			require((retirementMapping[ids[i]].amount == 0) || (from == address(0) || to == address(0)), "11");
		}
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}

	function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
		_setURI(newuri);
	}

	function pause() public onlyRole(PAUSER_ROLE) {
		_pause();
	}

	function unpause() public onlyRole(PAUSER_ROLE) {
		_unpause();
	}

	function nextTokenId() internal returns (uint256) {
		unchecked {
			topTokenId += 1;
		}
		return topTokenId;
	}

	function _authorizeUpgrade(
		address newImplementation
	) internal override onlyRole(UPGRADER_ROLE) {}

	// The following functions are overrides required by Solidity.

	function supportsInterface(
		bytes4 interfaceId
	)
		public
		view
		override(ERC1155Upgradeable, AccessControlUpgradeable,ERC1155ReceiverUpgradeable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}

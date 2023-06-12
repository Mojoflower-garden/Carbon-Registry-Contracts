// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '../types/ProjectTypes.sol';

interface IProject {
	event ExPostCreated(
		uint256 indexed tokenId,
		uint256 estimatedAmount,
		uint256 verificationPeriodStart,
		uint256 verificationPeriodEnd,
		string serialization
	);

	event VintageMitigationEstimateChanged(
		uint256 indexed tokenId,
		uint256 newEstimate,
		uint256 oldEstimate,
		AdminActionReason indexed reason
	);

	event ExAnteMinted(
		uint256 indexed exAnteTokenId,
		uint256 indexed exPostTokenId,
		address indexed account,
		uint256 amount
	);

	event ExPostVerifiedAndMinted(
		uint256 indexed tokenId,
		uint256 amount,
		uint256 amountToAnteHolders,
		uint256 verificationPeriodStart,
		uint256 verificationPeriodEnd,
		string monitoringReport
	);

	event AdminBurn(
		address indexed from,
		uint256 indexed tokenId,
		uint256 amount,
		AdminActionReason indexed reason
	);

	event AdminClawback(
		address indexed from,
		address to,
		uint256 indexed tokenId,
		uint256 amount,
		AdminActionReason indexed reason
	);

	event ExchangeAnteForPost(
		address indexed account,
		uint256 indexed exPostTokenId,
		uint256 exPostAmountReceived,
		uint256 exAnteAmountBurned
	);

	event RetiredVintage(
		address indexed account,
		uint256 indexed tokenId,
		uint256 amount,
		uint256 nftTokenId,
		bytes data
	);

	event CancelledCredits(
		address indexed account, 
		uint256 indexed tokenId, 
		uint256 amount, 
		string reason,
		bytes data
		);

	function retire(
		uint256 tokenId,
		uint256 amount,
		address retiree,
		string memory retireeName,
		string memory customUri,
		string memory comment,
		bytes memory data
	) external returns (uint256 nftTokenId) ;
}
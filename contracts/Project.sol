// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./ProjectStorage.sol";
import "./interfaces/ICarbonContractRegistry.sol";
import "./utils/CustomSignaturesUpgradeable.sol";

contract Project is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable,
    CustomSignaturesUpgradeable,
    ProjectStorage
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ANTE_MINTER_ROLE = keccak256("ANTE_MINTER_ROLE");
    bytes32 public constant POST_MINTER_ROLE = keccak256("POST_MINTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant BLACKLISTED = keccak256("BLACKLISTED");
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant CLAWBACK_ROLE = keccak256("CLAWBACK_ROLE");

    event ExPostCreated(
        uint256 indexed tokenId,
        uint256 estimatedAmount,
        string indexed serialization
    );

    event VintageMitigationEstimateChanged(
        uint256 indexed tokenId,
        uint256 newEstimate,
        uint256 oldEstimate,
        AdminActionReason indexed reason
    );

    event ExAnteMinted(
        address indexed account,
        uint256 indexed tokenId,
        uint256 amount
    );

    event ExPostVerifiedAndMinted(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 amountToAnteHolders,
        string monitoringReport,
        bool isVintageFullyVerified
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
        uint256 amount
    );

    event SignedTransfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 amount
    );

    event SignedRetire(
        address indexed from,
        uint256 indexed tokenId,
        uint256 amount
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _contractRegistry,
        address _owner,
        uint256 _projectId,
        string memory _projectName
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __Pausable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        __CustomSignatures_init(_projectName, "0.0.1");

        // Our Inits
        __ProjectStorage_init(_contractRegistry, 50, _projectId, _projectName);

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(URI_SETTER_ROLE, _owner);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(ANTE_MINTER_ROLE, _owner);
        _grantRole(POST_MINTER_ROLE, _owner);
        _grantRole(UPGRADER_ROLE, _owner);
        _grantRole(BLACKLISTER_ROLE, _owner);

        _grantRole(POST_MINTER_ROLE, msg.sender); // Just so projectFactory can mint exPost on creation of the project
    }

    modifier notBlacklisted(address account) {
        require(
            !hasRole(BLACKLISTED, account),
            "Project: Account is blacklisted"
        );
        _;
    }

    modifier onlyExPostTokens(uint256[] memory tokenIds) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(isExPostToken(tokenIds[i]), "Project: Token is not ExPost");
        }
        _;
    }

    modifier onlyExPostToken(uint256 tokenId) {
        require(isExPostToken(tokenId), "Project: Token is not ExPost");
        _;
    }

    function isExPostToken(uint256 tokenId) public view returns (bool) {
        return bytes(exPostVintageMapping[tokenId].serialization).length > 0;
    }

    modifier onlyVerifiedStatus(bool isVerified, uint256 tokenId) {
        require(
            exPostVintageMapping[tokenId].verified == isVerified,
            "Project: Token is already verified"
        );
        _;
    }

    // ----------------------------------
    //         Minting Functions
    // ----------------------------------

    function createExPostVintage(
        uint256 estAmount,
        string memory serialization
    ) public onlyRole(POST_MINTER_ROLE) {
        uint256 newTokenId = nextTokenId();
        ICarbonContractRegistry(contractRegistry).registerSerialization(
            serialization
        );
        serializationToExPostTokenIdMapping[serialization] = newTokenId;
        exPostVintageMapping[newTokenId] = VintageData(
            serialization,
            estAmount,
            false
        );
        emit ExPostCreated(newTokenId, estAmount, serialization);
    }

    function createExPostVintageBatch(
        uint256[] memory estAmounts,
        string[] memory serializations
    ) public onlyRole(POST_MINTER_ROLE) {
        require(
            estAmounts.length == serializations.length,
            "Project: Amounts and serializations must be same length"
        );
        for (uint256 i = 0; i < estAmounts.length; i++) {
            createExPostVintage(estAmounts[i], serializations[i]);
        }
    }

    function mintExAnte(
        address account,
        uint256 exPostTokenId,
        uint256 amount,
        bytes memory data
    ) public onlyRole(ANTE_MINTER_ROLE) onlyExPostToken(exPostTokenId) {
        uint256 exAnteTokenId = exPostToExAnteTokenId[exPostTokenId];
        if (exAnteTokenId == 0) {
            exAnteTokenId = nextTokenId();
            exPostToExAnteTokenId[exPostTokenId] = exAnteTokenId;
        }

        uint256 exPostEstimatedSupply = exPostVintageMapping[exPostTokenId]
            .estMitigations;
        uint256 maxExAnteSupply = (exPostEstimatedSupply *
            (maxAntePercentage)) / (100);
        uint256 exAnteSupply = totalSupply(exAnteTokenId);

        require(
            exAnteSupply + amount <= maxExAnteSupply,
            "Maximum exAnte supply exceeded"
        );

        exAnteToExPostTokenId[exAnteTokenId] = exPostTokenId;
        _mint(account, exAnteTokenId, amount, data);
        emit ExAnteMinted(account, exAnteTokenId, amount);
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
        bool isVintageVerificationComplete,
        string memory monitoringReport
    )
        public
        onlyRole(VERIFIER_ROLE)
        onlyExPostToken(tokenId)
        onlyVerifiedStatus(false, tokenId)
    {
        require(
            amountVerified >= amountToAnteHolders,
            "Project: Invalid amount"
        );

        uint256 exAnteTokenId = exPostToExAnteTokenId[tokenId];
        if (exAnteTokenId == 0) {
            // If exAnteTokenId is zero then there are no ante holders
            require(amountToAnteHolders == 0, "Project: Invalid amount");
        }

        exPostVintageMapping[tokenId].verified = isVintageVerificationComplete;

        if (amountVerified - amountToAnteHolders > 0) {
            // Mint To Verification Vault
            _mint(
                verificationVault,
                tokenId,
                amountVerified - amountToAnteHolders,
                ""
            );
        }

        if (amountToAnteHolders > 0) {
            // Mint to this address, where ante holders will claim
            _mint(address(this), tokenId, amountToAnteHolders, "");
        }

        emit ExPostVerifiedAndMinted(
            tokenId,
            amountVerified,
            amountToAnteHolders,
            monitoringReport,
            isVintageVerificationComplete
        );
    }

    function adminBurn(
        address from,
        uint256 tokenId,
        uint256 amount,
        AdminActionReason reason
    ) public onlyRole(BURNER_ROLE) {
        _burn(from, tokenId, amount);
        emit AdminBurn(from, tokenId, amount, reason);
    }

    function adminClawback(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        AdminActionReason reason
    ) public onlyRole(CLAWBACK_ROLE) {
        _safeTransferFrom(from, to, tokenId, amount, "");
        emit AdminClawback(from, to, tokenId, amount, reason);
    }

    function exchangeAnteForPostEvenSteven(
        address[] memory accounts,
        uint256 exPostTokenId,
        bytes memory data
    )
        external
        onlyExPostToken(exPostTokenId)
        onlyVerifiedStatus(true, exPostTokenId)
    {
        uint256 exAnteTokenId = exPostToExAnteTokenId[exPostTokenId];
        require(exAnteTokenId != 0, "Project: No ante holders");
        uint256 currentExAnteSupply = totalSupply(exAnteTokenId);
        uint256 currentExPostSupplyInContract = balanceOf(
            address(this),
            exPostTokenId
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 amountExAnte = balanceOf(accounts[i], exAnteTokenId);
            uint256 amountExPost = (amountExAnte *
                currentExPostSupplyInContract) / currentExAnteSupply;
            uint256 exAnteBurnAmount = amountExAnte;
            if (amountExAnte > amountExPost) {
                exAnteBurnAmount = amountExPost;
            }
            _burn(accounts[i], exAnteTokenId, exAnteBurnAmount);
            _safeTransferFrom(
                address(this),
                accounts[i],
                exPostTokenId,
                amountExPost,
                data
            );
            emit ExchangeAnteForPost(
                accounts[i],
                exPostTokenId,
                amountExPost,
                exAnteBurnAmount
            );
        }
    }

    function getExPostVintageData(
        uint256 exAnteTokenId
    ) public view returns (VintageData memory) {
        uint256 exPostTokenId = exAnteToExPostTokenId[exAnteTokenId];
        return exPostVintageMapping[exPostTokenId];
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
        emit SignedTransfer(
            payload.signer,
            payload.to,
            payload.tokenId,
            payload.amount
        );
    }

    function retire(
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public onlyExPostToken(tokenId) onlyVerifiedStatus(true, tokenId) {
        _burn(msg.sender, tokenId, amount);
        mintRetirementCertificate(msg.sender, tokenId, amount);
        emit RetiredVintage(msg.sender, tokenId, amount);
    }

    function retireFromSignature(
        bytes calldata signature,
        signatureTransferPayload calldata payload
    )
        public
        payable
        onlyExPostToken(payload.tokenId)
        onlyVerifiedStatus(true, payload.tokenId)
        onlyValidSignatureTransfer(signature, payload)
    {
        _burn(payload.signer, payload.tokenId, payload.amount);
        mintRetirementCertificate(
            payload.signer,
            payload.tokenId,
            payload.amount
        );
        emit SignedRetire(payload.signer, payload.tokenId, payload.amount);
    }

    function mintRetirementCertificate(
        address account,
        uint256 tokenId,
        uint256 amount
    ) internal {
        uint256 nftTokenId = nextTokenId();
        retirementMapping[nftTokenId] = RetirementData(
            account,
            amount,
            tokenId,
            "",
            "",
            ""
        );
        _mint(account, nftTokenId, 1, "");
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
            tokenId += 1;
        }
        return tokenId;
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
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

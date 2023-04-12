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

contract Project is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable,
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

    event ExPostMinted(
        address indexed account,
        uint256 indexed tokenId,
        uint256 amount,
        string indexed serialization
    );

    event SupplyChanged(
        uint256 indexed tokenId,
        uint256 amount,
        AdminActionReason indexed reason,
        bytes data
    );

    event ExPostVerified(
        uint256 indexed tokenId,
        uint256 amount,
        string indexed serialization,
        string monitoringReport,
        bool isVerified
    );

    event AdminClawback(
        address indexed from,
        address to,
        uint256 indexed tokenId,
        uint256 amount,
        AdminActionReason indexed reason,
        bytes data
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

    // Disallow sending tokens to other addresses that are ExPost and non-verified
    modifier isTransferAllowed(
        address from,
        address to,
        uint256[] memory tokenIds
    ) {
        bool isSupplyDecrease = from == address(this) && to == address(0);
        if (isSupplyDecrease || to == address(this)) {
            _;
            return;
        }
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                vintageMapping[tokenIds[i]].verified ||
                    vintageMapping[tokenIds[i]].tokenType != TokenType.ExPost,
                "Project: Token is non-verified"
            );
        }
        _;
    }

    function setTokenMintable(
        uint256 tokenId,
        bool isMintable
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isTokenMintable[tokenId] = isMintable;
    }

    function setTokenClawbackEnabled(
        uint256 tokenId,
        bool isClawbackEnabled
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isTokenClawbackEnabled[tokenId] = isClawbackEnabled;
    }

    // ----------------------------------
    //         Minting Functions
    // ----------------------------------

    function mintExAnte(
        address account,
        uint256 exPostTokenId,
        uint256 amount,
        bytes memory data
    ) public onlyRole(ANTE_MINTER_ROLE) {
        require(
            vintageMapping[exPostTokenId].tokenType == TokenType.ExPost,
            "Project: Token is not exPost"
        );
        uint256 exAnteTokenId = exPostToExAnteTokenId[exPostTokenId];
        if (exAnteTokenId == 0) {
            exAnteTokenId = nextTokenId();
            exPostToExAnteTokenId[exPostTokenId] = exAnteTokenId;
        }
        uint256 exPostSupply = totalSupply(exPostTokenId);
        uint256 maxExAnteSupply = (exPostSupply * (maxAntePercentage)) / (100);
        uint256 exAnteSupply = totalSupply(exAnteTokenId);

        require(
            exAnteSupply + amount <= maxExAnteSupply,
            "Maximum exAnte supply exceeded"
        );

        isTokenMintable[exAnteTokenId] = true;
        isTokenClawbackEnabled[exAnteTokenId] = true;
        vintageMapping[exAnteTokenId] = VintageData(
            vintageMapping[exPostTokenId].serialization,
            false,
            TokenType.ExAnte
        );

        _mint(account, exAnteTokenId, amount, data);
    }

    function mintExPost(
        uint256 amount,
        string memory serialization,
        bytes memory data
    ) public onlyRole(POST_MINTER_ROLE) {
        uint256 newTokenId = nextTokenId();
        ICarbonContractRegistry(contractRegistry).registerSerialization(
            serialization
        );
        serializationToTokenIdMapping[serialization] = newTokenId;
        isTokenMintable[newTokenId] = true;
        isTokenClawbackEnabled[newTokenId] = true;
        vintageMapping[newTokenId] = VintageData(
            serialization,
            false,
            TokenType.ExPost
        );
        _mint(address(this), newTokenId, amount, data);
        emit ExPostMinted(address(this), newTokenId, amount, serialization);
    }

    function mintExPostBatch(
        uint256[] memory amounts,
        string[] memory serializations,
        bytes memory data
    ) public onlyRole(POST_MINTER_ROLE) {
        require(
            amounts.length == serializations.length,
            "Project: Amounts and serializations must be same length"
        );
        for (uint256 i = 0; i < amounts.length; i++) {
            mintExPost(amounts[i], serializations[i], data);
        }
    }

    function increaseExPostSupply(
        uint256 tokenId,
        uint256 amount,
        AdminActionReason reason,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        require(
            vintageMapping[tokenId].tokenType == TokenType.ExPost,
            "Project: Token is not exPost"
        );
        _mint(address(this), tokenId, amount, data);
        emit SupplyChanged(tokenId, amount, reason, data);
    }

    function verifyExPost(
        address verificationVault,
        uint256 tokenId,
        uint256 amount,
        uint256 decreaseAmount,
        uint256 increaseAmount,
        bool isVintageVerificationComplete,
        string memory monitoringReport
    ) public onlyRole(VERIFIER_ROLE) {
        require(
            vintageMapping[tokenId].tokenType == TokenType.ExPost,
            "Project: Token is not exPost"
        );
        require(
            !vintageMapping[tokenId].verified,
            "Project: Token is verified"
        );
        require(
            !(decreaseAmount > 0 && increaseAmount > 0),
            "Project: Invalid supply change"
        );

        if (decreaseAmount > 0) {
            _burn(address(this), tokenId, amount);
        }

        if (increaseAmount > 0) {
            _mint(address(this), tokenId, amount, "");
            emit SupplyChanged(
                tokenId,
                amount,
                AdminActionReason.OverEstimated,
                ""
            );
        }

        // uint256 exAnteTokenId = exPostToExAnteTokenId[tokenId];
        // uint256 exPostSupply = totalSupply(tokenId);
        // uint256 exAnteSupply = totalSupply(exAnteTokenId);
        // require(
        //     exPostSupply - exAnteSupply >= amount,
        //     "Project: Token amount is incorrect"
        // );

        vintageMapping[tokenId].verified = isVintageVerificationComplete;
        _safeTransferFrom(
            address(this),
            verificationVault,
            tokenId,
            amount,
            ""
        );

        emit ExPostVerified(
            tokenId,
            amount,
            vintageMapping[tokenId].serialization,
            monitoringReport,
            isVintageVerificationComplete
        );
    }

    function adminBurn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) public onlyRole(BURNER_ROLE) {
        _burn(from, tokenId, amount);
    }

    function adminClawback(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        AdminActionReason reason
    ) public onlyRole(CLAWBACK_ROLE) {
        require(
            isTokenClawbackEnabled[tokenId],
            "Project: Clawback is not enabled"
        );
        _safeTransferFrom(from, to, tokenId, amount, "");
        _burn(from, tokenId, amount);
    }

    function exchangeExAnteForExPost(
        uint256 exPostTokenId,
        address[] memory exAnteHolders
    ) public {
        require(
            vintageMapping[exPostTokenId].tokenType == TokenType.ExPost &&
                vintageMapping[exPostTokenId].verified,
            "Project: Token is not verified "
        );
        uint256 exAnteTokenId = exPostToExAnteTokenId[exPostTokenId];
        uint256 currentExAnteSupply = totalSupply(exAnteTokenId);
        uint256 currentExPostSupplyInContract = balanceOf(
            address(this),
            exPostTokenId
        );
        for (uint i = 0; i < exAnteHolders.length; i++) {
            uint256 balance = balanceOf(exAnteHolders[i], exAnteTokenId);
            uint256 exPostAmount = (balance * currentExPostSupplyInContract) /
                currentExAnteSupply;
            if (balance > 0) {
                _safeTransferFrom(
                    address(this),
                    exAnteHolders[i],
                    exPostTokenId,
                    exPostAmount,
                    ""
                );
                _burn(exAnteHolders[i], exAnteTokenId, balance);
            }
        }
        require(
            totalSupply(exAnteTokenId) == 0,
            "Project: ExAnte token supply is not zero"
        );
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
        isTransferAllowed(from, to, ids)
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

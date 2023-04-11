// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./ProjectStorage.sol";

contract Project is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155BurnableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable,
    ProjectStorage
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ANTE_MINTER_ROLE = keccak256("ANTE_MINTER_ROLE");
    bytes32 public constant POST_MINTER_ROLE = keccak256("POST_MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter internal tokenCounter;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();

        // Our Inits
        __ProjectStorage_init(50);

        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(URI_SETTER_ROLE, owner);
        _grantRole(PAUSER_ROLE, owner);
        _grantRole(ANTE_MINTER_ROLE, owner);
        _grantRole(POST_MINTER_ROLE, owner);
        _grantRole(UPGRADER_ROLE, owner);
    }

    event ExPostMinted(
        address indexed account,
        uint256 indexed tokenId,
        uint256 amount,
        string indexed serialization
    );

    modifier onlySerializationNotRegistered(string memory serialization) {
        // require(
        //     IContractRegistry(contractRegistry).getSerializationAddress(
        //         serialization
        //     ) == address(0),
        //     "Serialization already registered"
        // );
        _;
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

    function mintExPost(
        address account,
        uint256 amount,
        string memory serialization,
        bytes memory data
    )
        public
        onlyRole(POST_MINTER_ROLE)
        onlySerializationNotRegistered(serialization)
    {
        uint256 newTokenId = nextTokenId();
        // IContractRegistry(contractRegistry).registerSerialization(
        //     serialization,
        //     address(this)
        // );
        serializationToTokenIdMapping[serialization] = newTokenId;
        isTokenMintable[newTokenId] = true;
        isTokenClawbackEnabled[newTokenId] = true;
        vintageMapping[newTokenId] = VintageData(
            serialization,
            false,
            TokenType.ExPost
        );
        _mint(account, newTokenId, amount, data);
        emit ExPostMinted(account, newTokenId, amount, serialization);
    }

    // function mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data
    // ) public onlyRole(MINTER_ROLE) {
    //     _mintBatch(to, ids, amounts, data);
    // }

    // -----------------
    //      Hooks
    // -----------------

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
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function nextTokenId() internal returns (uint256) {
        tokenCounter.increment();
        return tokenCounter.current();
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "./MarketplaceVaultStorage.sol";
import "../interfaces/IProject.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

contract MarketplaceVault is Initializable, AccessControlUpgradeable, ERC1155HolderUpgradeable, MarketplaceVaultStorage {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant FUND_MOVER_ROLE = keccak256("FUND_MOVER_ROLE");
    enum TransferReason{
        OTHER,
        DELISTING
    }

    event CreditVaultTransfer(
        address token,
        address to,
        address previousOwner,
        uint256 tokenId,
        uint256 amount,
        TransferReason reason
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _owner, string memory _name) initializer public {
        __AccessControl_init();
        __ERC1155Holder_init();
        
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(UPGRADER_ROLE, _owner);
        _grantRole(FUND_MOVER_ROLE, _owner);

        name = _name;
    }

    modifier balanceCheck(address owner, address token, uint256 tokenId, uint256 amount) {
        require(balances[token][tokenId][owner] >= amount, "Insufficient balance");
        _;
    }

    function transferERC1155(
        address token,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external onlyRole(FUND_MOVER_ROLE) {
        IERC1155Upgradeable(token).safeTransferFrom(address(this), to, tokenId, amount, data);
    }

    function transferCredit(
        address token,
        address previousOwner,
        uint256 tokenId,
        uint256 amount,
        TransferReason reason,
        bytes memory data
    ) external onlyRole(FUND_MOVER_ROLE) balanceCheck(previousOwner, token, tokenId, amount) {
        IERC1155Upgradeable(token).safeTransferFrom(address(this), previousOwner, tokenId, amount, data);
        balances[token][tokenId][previousOwner] -= amount;

        emit CreditVaultTransfer(
            token,
            previousOwner,
            previousOwner,
            tokenId,
            amount,
            reason
        );
    }

    struct RetireData{
        address token;
        uint256 tokenId;
        uint256 amount;
        address retiree;
        string retireeName;
        string customUri;
        string comment;
    }

    function retireCredit(
        address previousOwner,
        RetireData memory retireData,
		bytes memory data
        ) public onlyRole(FUND_MOVER_ROLE) balanceCheck(previousOwner, retireData.token, retireData.tokenId, retireData.amount) {
            IProject(retireData.token).retire(
                retireData.tokenId,
                retireData.amount,
                retireData.retiree,
                retireData.retireeName,
                retireData.customUri,
                retireData.comment,
                data
            );

            balances[retireData.token][retireData.tokenId][previousOwner] -= retireData.amount;
        }


    	function supportsInterface(
		bytes4 interfaceId
	)
		public
		view
		override(AccessControlUpgradeable,ERC1155ReceiverUpgradeable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}

    function onERC1155Received(
        address,
        address from ,
        uint256 tokenId,
        uint256 value,
        bytes memory
    ) public override returns (bytes4) {
        address tokenContract = _msgSender();
        balances[tokenContract][tokenId][from] += value;
        return this.onERC1155Received.selector;
    }
}
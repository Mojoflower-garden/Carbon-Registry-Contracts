// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./TokenVaultStorage.sol";

contract TokenVault is Initializable, AccessControlUpgradeable, ERC1155HolderUpgradeable, TokenVaultStorage {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant FUND_MOVER_ROLE = keccak256("FUND_MOVER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner) initializer public {
        __AccessControl_init();
        __ERC1155Holder_init();
        
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(UPGRADER_ROLE, owner);
        _grantRole(FUND_MOVER_ROLE, owner);
    }

    function transferERC1155(
        address token,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyRole(FUND_MOVER_ROLE) {
        IERC1155(token).safeTransferFrom(address(this), to, id, amount, data);
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
}
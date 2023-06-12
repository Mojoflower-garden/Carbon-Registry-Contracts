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

    function transferERC1155(
        address token,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external onlyRole(FUND_MOVER_ROLE) {
        IERC1155Upgradeable(token).safeTransferFrom(address(this), to, tokenId, amount, data);
    }

    function retireCredit(
        address token,
        uint256 tokenId,
		uint256 amount,
		address retiree,
		string memory retireeName,
		string memory customUri,
		string memory comment,
		bytes memory data
        ) public onlyRole(FUND_MOVER_ROLE){
            IProject(token).retire(
                tokenId,
                amount,
                retiree,
                retireeName,
                customUri,
                comment,
                data
            );
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
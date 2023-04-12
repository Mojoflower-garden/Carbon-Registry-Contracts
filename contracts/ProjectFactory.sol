// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ICarbonContractRegistry.sol";

contract ProjectFactory is Ownable {
    address private _carbonContractRegistry;

    event ProjectCreated(
        address indexed projectAddress,
        uint256 indexed projectId,
        string projectName
    );
    event CarbonContractRegistrySet(
        address indexed carbonContractRegistry,
        address indexed oldCarbonContractRegistry
    );

    constructor(address carbonContractRegistry_) {
        _carbonContractRegistry = carbonContractRegistry_;
    }

    function createProject(
        uint256 _projectId,
        string calldata _projectName
    ) external onlyOwner returns (address) {
        /// @dev generate payload for initialize function
        ICarbonContractRegistry carbonContractRegistry = ICarbonContractRegistry(
                _carbonContractRegistry
            );
        string memory signature = "initialize(address,uint256,string)";
        bytes memory payload = abi.encodeWithSignature(
            signature,
            owner(),
            _projectId,
            _projectName
        );

        address projectAddress = address(
            new BeaconProxy(carbonContractRegistry.getBeaconAddress(), payload)
        );

        carbonContractRegistry.setProjectIdAddress(_projectId, projectAddress);
        emit ProjectCreated(projectAddress, _projectId, _projectName);
        return projectAddress;
    }

    function setCarbonContractRegistry(
        address carbonContractRegistry_
    ) external onlyOwner {
        emit CarbonContractRegistrySet(
            carbonContractRegistry_,
            _carbonContractRegistry
        );
        _carbonContractRegistry = carbonContractRegistry_;
    }
}

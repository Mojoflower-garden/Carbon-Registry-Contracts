// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProjectFactory is Ownable {
    address private _beacon;

    constructor(address beacon_) {
        _beacon = beacon_;
    }

    function createProject() external onlyOwner returns (address) {
        /// @dev generate payload for initialize function
        string memory signature = "initialize()";
        bytes memory payload = abi.encodeWithSignature(signature);

        return address(new BeaconProxy(_beacon, payload));
    }

    function setBeacon(address beacon_) external onlyOwner {
        _beacon = beacon_;
    }
}

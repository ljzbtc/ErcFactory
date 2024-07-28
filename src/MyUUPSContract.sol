// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyUUPSContract is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 private _value;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 initialValue) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        _value = initialValue;
    }

    function setValue(uint256 newValue) public onlyOwner {
        _value = newValue;
    }

    function getValue() public view returns (uint256) {
        return _value;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
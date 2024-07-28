// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyUpgradeableContract is Initializable, OwnableUpgradeable {
    uint256 private _value;

    function initialize(uint256 initialValue) public initializer {
        __Ownable_init(msg.sender);
        _value = initialValue;
    }

    function setValue(uint256 newValue) public onlyOwner {
        _value = newValue;
    }

    function getValue() public view returns (uint256) {
        return _value;
    }
}
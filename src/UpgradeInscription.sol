//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UpgradeInscription is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    uint public PER_MINT;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory symbol,
        uint totalSupply,
        uint perMint
    ) public initializer {
        __ERC20_init(symbol, symbol);
        __Ownable_init(msg.sender);
        
        _mint(msg.sender, totalSupply);
        PER_MINT = perMint;
    }

    function mint() public onlyOwner {
        _mint(msg.sender, PER_MINT);
    }
}
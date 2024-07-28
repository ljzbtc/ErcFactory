// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

import "./NewInscription.sol";

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Erc20FactoryUpgradableV1 is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    // this function is check if the upgrade is authorized
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    event InscriptionDeployed(
        address indexed deloyer,
        address indexed inscription,
        string symbol
    );
    event InscriptionMinted(
        address indexed minter,
        address indexed inscription,
        string symbol
    );
    function deployInscription(
        string calldata symbol,
        uint totalSupply,
        uint perMint
    ) public returns (address) {
        NewInscription inscription = new NewInscription(
            symbol,
            totalSupply,
            perMint
        );
        emit InscriptionDeployed(msg.sender, address(inscription), symbol);
        return address(inscription);
    }
    function mintInscription(address tokenAddr) public payable {
        NewInscription inscription = NewInscription(tokenAddr);
        inscription.mint();
        emit InscriptionMinted(msg.sender, tokenAddr, inscription.symbol());
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NewInscription.sol";

contract Erc20FactoryV1 {
    uint MINT_FEE = 1 wei * 100;
    uint FACTORY_FEE = 1 wei;

    mapping(address => address) public inscriptionToOwner;

    event InscriptionDeployed(
        address indexed deloyer,
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
        inscriptionToOwner[address(inscription)] = msg.sender;
        emit InscriptionDeployed(msg.sender, address(inscription), symbol);
        return address(inscription);
    }
    function mintInscription(address tokenAddr) public payable {
        require(msg.value == MINT_FEE, "Erc20FactoryV2: mint fee not met");

        (bool success, ) = payable(inscriptionToOwner[tokenAddr]).call{
            value: MINT_FEE - FACTORY_FEE
        }("");
        require(success, "Transfer failed");

        NewInscription inscription = NewInscription(tokenAddr);
        inscription.mint(msg.sender);
    }
}

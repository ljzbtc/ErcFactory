//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NewInscription.sol";

contract Erc20FactoryV1 {

    event InscriptionDeployed(address indexed deloyer, address indexed inscription, string symbol);
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
    function mintInscription(address tokenAddr) payable public {

        NewInscription inscription = NewInscription(tokenAddr);
        inscription.mint();
    }
}

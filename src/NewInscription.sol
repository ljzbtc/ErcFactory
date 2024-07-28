//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NewInscription is ERC20, Ownable {
    uint public immutable PER_MINT;
    constructor(
        string memory symbol,
        uint totalSupply,
        uint perMint
    ) ERC20(symbol, symbol)Ownable(msg.sender) {

        _mint(msg.sender, totalSupply);
        PER_MINT = perMint;

    }

    function mint(address _minter) public payable onlyOwner(){
        _mint(_minter, PER_MINT);
    }
}

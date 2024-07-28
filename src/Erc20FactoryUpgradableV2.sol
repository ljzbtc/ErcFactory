// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INewInscription is IERC20 {
    function initialize(string memory symbol, uint256 totalSupply, uint256 perMint) external;
    function mint() external;
    function symbol() external view returns (string memory);
}

contract Erc20FactoryUpgradableV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using Clones for address;

    address public InscriptionImplementationContract;
    mapping(address => uint256) public inscriptionsToPrice;

    event InscriptionDeployed(address indexed deployer, address indexed inscription, string symbol);
    event InscriptionMinted(address indexed minter, address indexed inscription, string symbol);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setInscriptionImplementationContract(address _newImplementation) external onlyOwner {
        InscriptionImplementationContract = _newImplementation;
    }

    function deployInscription(
        string calldata symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    ) public returns (address) {
        address clone = InscriptionImplementationContract.clone();
        INewInscription(clone).initialize(symbol, totalSupply, perMint);
        inscriptionsToPrice[clone] = price;
        emit InscriptionDeployed(msg.sender, clone, symbol);
        return clone;
    }

    function mintInscription(address tokenAddr) public payable {
        uint256 price = inscriptionsToPrice[tokenAddr];
        require(msg.value == price, "Insufficient payment");
        
        INewInscription inscription = INewInscription(tokenAddr);
        require(inscription.balanceOf(msg.sender) > 0, "Not token owner");
        
        inscription.mint();
        
        emit InscriptionMinted(msg.sender, tokenAddr, inscription.symbol());
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}
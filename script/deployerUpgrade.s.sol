// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
// import {Erc20FactoryV1} from "src/Erc20FactoryV1.sol";


// import {Script, console} from "forge-std/Script.sol";


// contract DeployScript is Script {

//     function run() external returns (address, address) {

//         // Deploy the upgradeable contract
//         address _proxyAddress = Upgrades.upgradeProxy(
//             "Erc20FactoryV1.sol"
//             // msg.sender,
//             // abi.encodeCall(MyUpgradeableToken.initialize, (msg.sender))
//         );

//         // Get the implementation address
//         address implementationAddress = Upgrades.getImplementationAddress(
//             _proxyAddress
//         );

//         vm.stopBroadcast();

//         return (implementationAddress, _proxyAddress);
//     }
// }

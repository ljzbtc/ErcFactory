// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Erc20FactoryUpgradableV2.sol";
import "../src/UpgradeInscription.sol";

contract UpgradeUUPSScript is Script {
    // 请替换为您的实际代理合约地址
    address constant PROXY_ADDRESS = address(0x6E04D09003426B45972B0DDE346A292cD1E26Bc4);

    function run() external {
        vm.startBroadcast();

        // 部署新的工厂实现合约
        Erc20FactoryUpgradableV2 newImplementation = new Erc20FactoryUpgradableV2();

        // 部署新的 Inscription 实现合约
        UpgradeInscription newInscriptionImplementation = new UpgradeInscription();

        // 获取代理合约的实例
        Erc20FactoryUpgradableV2 proxy = Erc20FactoryUpgradableV2(PROXY_ADDRESS);

        // 升级到新的实现
        proxy.upgradeToAndCall(
            address(newImplementation),
            ""
        );

        // 设置新的 Inscription 实现合约
        proxy.setInscriptionImplementationContract(address(newInscriptionImplementation));

        vm.stopBroadcast();

        console.log("New Factory Implementation deployed at:", address(newImplementation));
        console.log("New Inscription Implementation deployed at:", address(newInscriptionImplementation));
        console.log("Proxy upgraded at:", PROXY_ADDRESS);
    }
}
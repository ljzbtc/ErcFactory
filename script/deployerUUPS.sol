// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/Erc20FactoryUpgradableV1.sol";

contract DeployUUPSScript is Script {
    function run() external {
        
        vm.startBroadcast();

        // 部署实现合约
        Erc20FactoryUpgradableV1 implementation = new Erc20FactoryUpgradableV1();

        // 编码初始化函数调用
        bytes memory data = abi.encodeWithSelector(
            Erc20FactoryUpgradableV1.initialize.selector
            
        );

        // 部署代理合约
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            data
        );

        vm.stopBroadcast();

        console.log("ImplementationV1 deployed at:", address(implementation));
        console.log("Factory Proxy deployed at:", address(proxy));
    }
}
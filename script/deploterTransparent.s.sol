// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "src/MyUpgradebleContract.sol";

contract DeployScriptTransparent is Script {
    function run() external {
        
        vm.startBroadcast();

        // 部署实现合约
        MyUpgradeableContract implementation = new MyUpgradeableContract();

        // 部署代理管理员
        ProxyAdmin proxyAdmin = new ProxyAdmin(msg.sender);

        // 编码初始化函数调用
        bytes memory data = abi.encodeWithSelector(
            MyUpgradeableContract.initialize.selector,
            uint256(100)
        );

        // 部署代理合约
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementation),
            address(proxyAdmin),
            data
        );

        vm.stopBroadcast();

        console.log("Implementation deployed at:", address(implementation));
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));
        console.log("Proxy deployed at:", address(proxy));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Erc20FactoryUpgradableV1.sol";
import "../src/Erc20FactoryUpgradableV2.sol";
import "../src/NewInscription.sol";
import "../src/UpgradeInscription.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Erc20FactoryUpgradeTest is Test {
    Erc20FactoryUpgradableV1 implementationV1;
    Erc20FactoryUpgradableV2 implementationV2;
    Erc20FactoryUpgradableV1 proxyAsV1;
    Erc20FactoryUpgradableV2 proxyAsV2;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy V1 implementation
        implementationV1 = new Erc20FactoryUpgradableV1();

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            Erc20FactoryUpgradableV1.initialize.selector
        );

        // Deploy proxy contract
        ERC1967Proxy proxyContract = new ERC1967Proxy(
            address(implementationV1),
            initData
        );

        // Cast proxy to V1 interface
        proxyAsV1 = Erc20FactoryUpgradableV1(address(proxyContract));

        vm.stopPrank();
    }

    function testDeployAndMintV1() public {
        vm.startPrank(user);

        address inscriptionAddress = proxyAsV1.deployInscription(
            "TEST",
            1000000,
            100
        );
        assertNotEq(
            inscriptionAddress,
            address(0),
            "Inscription should be deployed"
        );

        NewInscription inscription = NewInscription(inscriptionAddress);
        uint256 initialBalance = inscription.balanceOf(user);

        proxyAsV1.mintInscription(inscriptionAddress);

        uint256 newBalance = inscription.balanceOf(user);
        assertEq(
            newBalance,
            initialBalance + 100,
            "Balance should increase by PER_MINT amount"
        );

        vm.stopPrank();
    }

    function testUpgradeToV2() public {
        // Deploy V2 implementation
        vm.startPrank(owner);
        implementationV2 = new Erc20FactoryUpgradableV2();

        // Upgrade proxy to V2
        proxyAsV1.upgradeToAndCall(address(implementationV2), "");

        // Cast proxy to V2 interface
        proxyAsV2 = Erc20FactoryUpgradableV2(address(proxyAsV1));

        // Deploy UpgradeInscription implementation
        UpgradeInscription inscriptionImplementation = new UpgradeInscription();

        // Set new inscription implementation
        proxyAsV2.setInscriptionImplementationContract(
            address(inscriptionImplementation)
        );

        vm.stopPrank();

        // Test new V2 functionality
        vm.startPrank(user);

        address inscriptionAddress = proxyAsV2.deployInscription(
            "TESTV2",
            1000000,
            100,
            0.1 ether
        );
        assertNotEq(
            inscriptionAddress,
            address(0),
            "V2 Inscription should be deployed"
        );

        vm.deal(user, 1 ether);
        proxyAsV2.mintInscription{value: 0.1 ether}(inscriptionAddress);

        UpgradeInscription inscription = UpgradeInscription(inscriptionAddress);
        uint256 balance = inscription.balanceOf(user);
        assertEq(balance, 100, "Balance should be PER_MINT amount");

        vm.stopPrank();
    }

    function testStateShouldNotChangeAfterUpgrade() public {
        // 部署一个 Inscription 代币（V1 版本）
        vm.startPrank(user);
        address inscriptionAddress = proxyAsV1.deployInscription(
            "TEST",
            1000000,
            100
        );
        vm.label(inscriptionAddress, "InscriptionToken");

        // 在 V1 中铸造 100 个代币（不需要付费）
        proxyAsV1.mintInscription(inscriptionAddress);

        // 检查用户余额
        NewInscription inscription = NewInscription(inscriptionAddress);
        uint256 balanceAfterV1Mint = inscription.balanceOf(user);
        assertEq(
            balanceAfterV1Mint,
            100,
            "Balance after V1 mint 100"
        );

        vm.stopPrank();

        // 升级到 V2
        vm.startPrank(owner);
        implementationV2 = new Erc20FactoryUpgradableV2();
        vm.label(address(implementationV2), "ImplementationV2");

        proxyAsV1.upgradeToAndCall(address(implementationV2), "");

        proxyAsV2 = Erc20FactoryUpgradableV2(address(proxyAsV1));

        // 部署新的 Inscription 实现
        UpgradeInscription inscriptionImplementation = new UpgradeInscription();
        vm.label(
            address(inscriptionImplementation),
            "InscriptionImplementationV2"
        );

        proxyAsV2.setInscriptionImplementationContract(
            address(inscriptionImplementation)
        );

        
        
        vm.stopPrank();

        // 检查升级后用户余额是否保持不变
        uint256 balanceAfterUpgrade = inscription.balanceOf(user);
        assertEq(
            balanceAfterUpgrade,
            balanceAfterV1Mint,
            "Balance should not change after upgrade"
        );

        // 在 V2 中再次铸造代币（不需要付费，因为是从 V1 升级过来的）
        vm.prank(user);
        proxyAsV2.mintInscription{value: 0}(inscriptionAddress);


        // 检查 V2 铸造后的余额
        uint256 balanceAfterV2Mint = inscription.balanceOf(user);
        assertEq(
            balanceAfterV2Mint,
            balanceAfterUpgrade + 100,
            "Balance after V2 mint should increase by 100"
        );

        // 测试在 V2 中部署新的 Inscription（这个应该需要设置价格）
        vm.startPrank(user);
        address newInscriptionAddress = proxyAsV2.deployInscription(
            "TESTV2",
            1000000,
            100,
            0.1 ether
        );
        vm.label(newInscriptionAddress, "NewInscriptionTokenV2");

        // 尝试铸造新的 V2 Inscription（这个应该需要付费）
        vm.deal(user, 1 ether); // 确保用户有足够的 ETH
        proxyAsV2.mintInscription{value: 0.1 ether}(newInscriptionAddress);

        UpgradeInscription newInscription = UpgradeInscription(
            newInscriptionAddress
        );
        uint256 balanceNewV2Inscription = newInscription.balanceOf(user);
        assertEq(
            balanceNewV2Inscription,
            100,
            "Balance of new V2 Inscription should be 100"
        );

        vm.stopPrank();
    }
}

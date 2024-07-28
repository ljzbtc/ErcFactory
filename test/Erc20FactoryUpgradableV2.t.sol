// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Erc20FactoryUpgradableV2.sol";
import "../src/UpgradeInscription.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Erc20FactoryUpgradableV2Test is Test {
    Erc20FactoryUpgradableV2 implementation;
    Erc20FactoryUpgradableV2 proxy;
    UpgradeInscription inscriptionImplementation;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.startPrank(owner);

        // 部署实现合约
        implementation = new Erc20FactoryUpgradableV2();

        // 准备初始化数据
        bytes memory initData = abi.encodeWithSelector(
            Erc20FactoryUpgradableV2.initialize.selector
        );

        // 部署代理合约
        ERC1967Proxy proxyContract = new ERC1967Proxy(
            address(implementation),
            initData
        );

        // 将代理合约地址转换为 Erc20FactoryUpgradableV2 接口
        proxy = Erc20FactoryUpgradableV2(address(proxyContract));

        // 部署新的 Inscription 实现合约
        inscriptionImplementation = new UpgradeInscription();

        // 设置 InscriptionImplementationContract
        proxy.setInscriptionImplementationContract(
            address(inscriptionImplementation)
        );
        console.log("Proxy deployed at:", address(proxy));
        console.log("Implementation deployed at:", address(implementation));
        console.log(
            "Inscription Implementation deployed at:",
            address(inscriptionImplementation)
        );

        vm.stopPrank();
    }

    function testOwnership() public {
        assertEq(proxy.owner(), owner, "Owner should be set correctly");
    }

    function testDeployInscription() public {
        vm.startPrank(user);
        address inscriptionAddress = proxy.deployInscription(
            "TEST",
            1000000,
            100,
            0.1 ether
        );

        assertNotEq(
            inscriptionAddress,
            address(0),
            "Inscription should be deployed"
        );

        INewInscription inscription = INewInscription(inscriptionAddress);
        assertEq(inscription.symbol(), "TEST", "Symbol should match");
        assertEq(
            inscription.totalSupply(),
            1000000,
            "Total supply should match"
        );
        vm.stopPrank();
    }

    function testMintInscription() public {

        vm.startPrank(user);

        // 部署 Inscription
        address inscriptionAddress = proxy.deployInscription(
            "TEST",
            1000000,
            100,
            0.1 ether
        );

        // 确保用户成为代币所有者
        INewInscription inscription = INewInscription(inscriptionAddress);

        uint256 initialBalance = inscription.balanceOf(user);
        console.log("Initial balance:", initialBalance);
        console.log("TOKE SYmbol", inscription.symbol());
        console.log("TOKE totalSupply", inscription.totalSupply());

        // 铸造代币
        vm.deal(user, 1 ether);
        proxy.mintInscription{value: 0.1 ether}(inscriptionAddress);

        console.log("after balance:", initialBalance);

        uint256 newBalance = inscription.balanceOf(user);
        assertEq(
            newBalance,
            initialBalance + 100,
            "Balance should increase by PER_MINT amount"
        );

        vm.stopPrank();
    }

    function testFailMintInscriptionInsufficientPayment() public {
        vm.startPrank(user);
        address inscriptionAddress = proxy.deployInscription(
            "TEST",
            1000000,
            100,
            0.1 ether
        );

        vm.deal(user, 1 ether);
        proxy.mintInscription{value: 0.05 ether}(inscriptionAddress);
        vm.stopPrank();
    }





    // function testUpgrade() public {
    //     Erc20FactoryUpgradableV2 newImplementation = new Erc20FactoryUpgradableV2();

    //     vm.prank(owner);
    //     proxy.upgradeToAndCall(address(newImplementation), "");

    //     assertEq(ERC1967Proxy(payable(address(proxy))).implementation(), address(newImplementation), "Upgrade should change implementation");
    // }

    function testFailUpgradeNonOwner() public {
        Erc20FactoryUpgradableV2 newImplementation = new Erc20FactoryUpgradableV2();

        vm.prank(user);
        proxy.upgradeToAndCall(address(newImplementation), "");
    }
}

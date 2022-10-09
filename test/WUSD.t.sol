// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/mocks/ERC20Mock.sol";
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';

import "forge-std/Test.sol";

import "../src/wusd.sol";
import '../src/PreciseMath.sol';

contract WrappedUSDTest is Test {
    using PreciseMath for uint256;

    WrappedUSD public wusd;
    IERC20 public dai;

    uint256 constant AMOUNT = 1000 * 1e18;

    uint256 internal alicePk = 0xa11ce;
    uint256 internal bobPk = 0xb0b;

    address payable internal alice = payable(vm.addr(alicePk));
    address payable internal bob = payable(vm.addr(bobPk));

    function setUp() public {
        vm.label(alice, "alice");
        vm.label(bob, "bob");

        wusd = new WrappedUSD();
        dai = new ERC20Mock('DAI', 'DAI', alice, AMOUNT);
    }

    function testInit() public {
        assertEq(wusd.totalSupply(), 0);
        assertEq(wusd.name(), 'Wrapped USD');
        assertEq(wusd.symbol(), 'WUSD');
        assertEq(wusd.decimals(), 18);
    }

    function testMint() public {
        wusd.addLimit(address(dai), AMOUNT);
        vm.startPrank(alice);

        dai.approve(address(wusd), ~uint256(0));

        wusd.mint(address(dai), AMOUNT);

        assertEq(wusd.limits(address(dai)), 0);
        assertEq(wusd.balanceOf(alice), AMOUNT);
        assertEq(dai.balanceOf(alice), 0);

        vm.stopPrank();
    }

    function testMintFee() public {
        uint256 mintAmount = AMOUNT * 9 / 10;
        wusd.addLimit(address(dai), mintAmount);
        wusd.setMintFee(address(dai), 1e17);
        vm.startPrank(alice);

        dai.approve(address(wusd), ~uint256(0));

        wusd.mint(address(dai), AMOUNT);

        assertEq(wusd.limits(address(dai)), 0);
        assertEq(wusd.balanceOf(alice), mintAmount);
        assertEq(dai.balanceOf(alice), 0);

        vm.stopPrank();
    }

    function testBurn() public {
        wusd.addLimit(address(dai), AMOUNT);
        vm.startPrank(alice);

        dai.approve(address(wusd), ~uint256(0));

        wusd.mint(address(dai), AMOUNT);
        assertEq(wusd.balanceOf(alice), AMOUNT);
        assertEq(dai.balanceOf(alice), 0);
        assertEq(wusd.limits(address(dai)), 0);

        wusd.burn(address(dai), AMOUNT);
        assertEq(wusd.balanceOf(alice), 0);
        assertEq(dai.balanceOf(alice), AMOUNT);
        assertEq(wusd.limits(address(dai)), AMOUNT);

        vm.stopPrank();
    }

    function testBurnFee() public {
        uint256 sendAmount = AMOUNT * 9 / 10;
        wusd.addLimit(address(dai), AMOUNT);
        wusd.setBurnFee(address(dai), 1e17);
        vm.startPrank(alice);

        dai.approve(address(wusd), ~uint256(0));

        wusd.mint(address(dai), AMOUNT);
        assertEq(wusd.balanceOf(alice), AMOUNT);
        assertEq(dai.balanceOf(alice), 0);
        assertEq(wusd.limits(address(dai)), 0);

        wusd.burn(address(dai), AMOUNT);
        assertEq(wusd.balanceOf(alice), 0);
        assertEq(dai.balanceOf(alice), sendAmount);
        assertEq(wusd.limits(address(dai)), AMOUNT);

        vm.stopPrank();
    }

}

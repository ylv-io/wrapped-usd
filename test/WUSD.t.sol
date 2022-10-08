// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/wusd.sol";

contract WrappedUSDTest is Test {
    WrappedUSD public wusd;

    function setUp() public {
        wusd = new WrappedUSD();
    }

    function testInit() public {
        assertEq(wusd.totalSupply(), 0);
        assertEq(wusd.name(), 'Wrapped USD');
        assertEq(wusd.symbol(), 'WUSD');
        assertEq(wusd.decimals(), 18);
    }

}

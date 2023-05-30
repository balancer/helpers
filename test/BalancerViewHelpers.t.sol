// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {BalancerViewHelpers} from "../src/BalancerViewHelpers.sol";

contract BalancerViewHelpersTest is Test {
    BalancerViewHelpers helpers;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        vm.rollFork(16_540_800);
        helpers = new BalancerViewHelpers(address(0xBA12222222228d8Ba445958a75a0704d566BF2C8));
    }

    function test_poolTokens() public {
        (BalancerViewHelpers.PoolToken[] memory tokens) =
            helpers.poolTokens(bytes32(0x4ce0bd7debf13434d3ae127430e9bd4291bfb61f00020000000000000000038b));
        assertEq(
            tokens[tokens.length - 1].parentId,
            bytes32(0x4ce0bd7debf13434d3ae127430e9bd4291bfb61f00020000000000000000038b)
        );
        assertEq(tokens.length, 15);
    }
}

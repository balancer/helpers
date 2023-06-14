// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {BalancerViewHelpers} from "../src/BalancerViewHelpers.sol";

contract BalancerViewHelpersTest is Test {
    BalancerViewHelpers helpers;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        vm.rollFork(17_400_000);
        helpers = new BalancerViewHelpers(address(0xBA12222222228d8Ba445958a75a0704d566BF2C8));
    }

    function test_poolTokens() public {
        (BalancerViewHelpers.PoolToken[] memory tokens) =
            helpers.poolTokens(bytes32(0xfebb0bbf162e64fb9d0dfe186e517d84c395f016000000000000000000000502));
        assertEq(
            tokens[tokens.length - 1].parentId,
            bytes32(0xfebb0bbf162e64fb9d0dfe186e517d84c395f016000000000000000000000502)
        );
        assertEq(tokens.length, 13);
    }
}

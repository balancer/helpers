// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {BalancerViewHelpers} from "../src/BalancerViewHelpers.sol";

contract BalancerViewHelpersTest is Test {
    BalancerViewHelpers helpers;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        vm.rollFork(17_530_000);
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
        // console.log(tokens[1].addr, tokens[1].totalSupply, tokens[1].swapFee);
        // console.log(tokens[2].addr, tokens[2].totalSupply, tokens[2].swapFee);
        // console.log(tokens[3].addr, tokens[3].totalSupply, tokens[3].swapFee);
        // console.log(tokens[4].addr, tokens[4].totalSupply, tokens[4].swapFee);
        // console.log(tokens[5].addr, tokens[5].totalSupply, tokens[5].swapFee);
        // console.log(tokens[6].addr, tokens[6].totalSupply, tokens[6].swapFee);
    }
}

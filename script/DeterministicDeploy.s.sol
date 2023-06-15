// SPDX-License-Identifier: MIT 
pragma solidity >=0.8.17;

import { Script } from "forge-std/Script.sol";

import { BalancerViewHelpers } from "src/BalancerViewHelpers.sol";

contract DeterministicDeploy is Script {
  address internal constant DETERMINISTIC_CREATE2_FACTORY = 0x7A0D94F55792C434d74a40883C6ed8545E406D12;

  function run( ) public returns (BalancerViewHelpers helpers) {
    vm.startBroadcast();
    bytes memory creationBytecode = abi.encodePacked(
      type(BalancerViewHelpers).creationCode,
      abi.encode(0xBA12222222228d8Ba445958a75a0704d566BF2C8)
    );
    bytes memory returnData;
    (, returnData) = DETERMINISTIC_CREATE2_FACTORY.call(creationBytecode);
    helpers = BalancerViewHelpers(address (uint160(bytes20 (returnData))));
    vm.stopBroadcast();
  }
}

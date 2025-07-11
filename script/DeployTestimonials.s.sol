// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {TestimonialRegistry} from "../src/TestimonialRegistry.sol";

contract DeployTestimonials is Script {
    function run() external returns (TestimonialRegistry t) {
        // uint256 privateKey = vm.envUint("PRIVATE_KEY");
        uint256 privateKey = vm.envUint("HEDERA_PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        t = new TestimonialRegistry();
        vm.stopBroadcast();
        return t;
    }

    function testMock() public {}
}

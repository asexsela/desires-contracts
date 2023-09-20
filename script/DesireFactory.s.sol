// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/DesireFactory.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";

contract DesireFactoryScript is Script {
    IEntryPoint constant ENTRYPOINT = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DesireFactory desireFactory = new DesireFactory(ENTRYPOINT);

        vm.stopBroadcast();
    }
}

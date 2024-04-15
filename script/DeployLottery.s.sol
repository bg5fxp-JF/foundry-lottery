// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployLottery is Script {
    function run() public returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint64 subscriptionId,
            bytes32 gasLane,
            uint256 interval,
            uint256 entranceFee,
            uint32 callbackGasLimit,
            address vrfCoordinatorV2
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        Lottery lottery =
            new Lottery(subscriptionId, gasLane, interval, entranceFee, callbackGasLimit, vrfCoordinatorV2);

        vm.stopBroadcast();

        return (lottery, helperConfig);
    }
}

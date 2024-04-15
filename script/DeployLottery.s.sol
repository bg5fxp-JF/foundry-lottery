// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription} from "./Interactions.s.sol";

contract DeployLottery is Script {
    function run() public returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint64 subscriptionId,
            bytes32 gasLane,
            uint256 automationUpdateInterval,
            uint256 raffleEntranceFee,
            uint32 callbackGasLimit,
            address vrfCoordinatorV2,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (subscriptionId, vrfCoordinatorV2) = createSubscription.createSubscription(vrfCoordinatorV2, deployerKey);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinatorV2, subscriptionId, link, deployerKey);
        }

        Lottery lottery = new Lottery(
            subscriptionId, gasLane, automationUpdateInterval, raffleEntranceFee, callbackGasLimit, vrfCoordinatorV2
        );

        vm.stopBroadcast();

        return (lottery, helperConfig);
    }
}

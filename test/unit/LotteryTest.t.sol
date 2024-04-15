// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import {Lottery} from "../../src/Lottery.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract LotteryTest is Test {
    /* Events */
    event RequestedLotteryWinner(uint256 indexed requestId);
    event LotteryEnter(address indexed player);
    event WinnerPicked(address indexed player);

    Lottery lottery;
    HelperConfig helperConfig;
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant ENTRANCE_FEE = 0.01 ether;

    uint64 subscriptionId;
    bytes32 gasLane;
    uint256 interval;
    uint256 entranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2;

    function setUp() external {
        DeployLottery deployer = new DeployLottery();
        (lottery, helperConfig) = deployer.run();
        (subscriptionId, gasLane, interval, entranceFee, callbackGasLimit, vrfCoordinatorV2) =
            helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testLotteryInitialisesState() public view {
        assert(lottery.getLotteryState() == Lottery.LotteryState.OPEN);
    }

    function testLotterRevertsWhenYouDontPayEnough() public {
        vm.prank(PLAYER);

        vm.expectRevert(Lottery.Lottery__SendMoreToEnterLottery.selector);

        lottery.enterLottery();
    }

    function testPlayersArrayUpdatesWhenPlayerEnters() public {
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        assert(lottery.getPlayer(0) == PLAYER);
        assert(lottery.getNumberOfPlayers() == 1);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(lottery));

        emit LotteryEnter(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
    }

    function testCantEnterWhenLotteryIsCalculating() public {
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        vm.warp(block.timestamp + interval + 1);

        vm.roll(block.number + 1);

        lottery.performUpkeep("");
        vm.expectRevert(Lottery.Lottery__LotteryNotOpen.selector);
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
    }
}

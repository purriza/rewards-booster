// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "test/mocks/Token1.sol";
import "test/mocks/Token2.sol";
import "src/Pool.sol";
import "src/BoosterPack.sol";
import "src/TheToken.sol";

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

contract PoolFuzzingTest is
    Test
{
    Pool public pool;
    BoosterPack public boosterPack;
    Token1 public token1;
    Token2 public token2;

    address public deployer = vm.addr(1500);
    address public user1 = vm.addr(1501);
    address public user2 = vm.addr(1502);
    address public user3 = vm.addr(1503);
    address public userFuzz = vm.addr(1504);

    function setUp() public {
        // Label addresses
        vm.label(deployer, "Deployer");
        vm.label(user1, "User 1");
        vm.label(user2, "User 2");
        vm.label(user3, "User 3");
        vm.label(userFuzz, "User Fuzzing");

        vm.startPrank(deployer);

        token1 = new Token1();
        token2 = new Token2();
        boosterPack = new BoosterPack("");

        // Set the initial data
        // RewardsMultiplier
        uint64[] memory rewardsMultiplierBlocks = new uint64[](4);
        rewardsMultiplierBlocks[0] = 100;
        rewardsMultiplierBlocks[1] = 200;
        rewardsMultiplierBlocks[2] = 300;
        rewardsMultiplierBlocks[3] = 400;
        uint64[] memory rewardsMultipliers = new uint64[](4);
        rewardsMultipliers[0] = 100;
        rewardsMultipliers[1] = 50;
        rewardsMultipliers[2] = 25;
        rewardsMultipliers[3] = 10;

        // WithdrawFees
        uint64[] memory withdrawFeeBlocks = new uint64[](4);
        withdrawFeeBlocks[0] = 0;
        withdrawFeeBlocks[1] = 100;
        withdrawFeeBlocks[2] = 1000;
        withdrawFeeBlocks[3] = 10_000;
        uint64[] memory withdrawFees = new uint64[](4);
        withdrawFees[0] = 15;
        withdrawFees[1] = 10;
        withdrawFees[2] = 5;
        withdrawFees[3] = 2;

        pool =
        new Pool(address(token1), deployer, 20, 10, rewardsMultiplierBlocks, rewardsMultipliers, withdrawFeeBlocks, withdrawFees, address(boosterPack));

        // Deal the accounts
        token1.mint(user1, 1000);
        token1.mint(user2, 1000);
        token1.mint(user3, 1000);

        token2.mint(user1, 1000);
        token2.mint(user2, 1000);
        token2.mint(user3, 1000);

        vm.stopPrank();
    }

    function test_constructor() public {
        // Set the initial data
        // RewardsMultiplier
        uint64[] memory rewardsMultiplierBlocks = new uint64[](4);
        rewardsMultiplierBlocks[0] = 100;
        rewardsMultiplierBlocks[1] = 200;
        rewardsMultiplierBlocks[2] = 300;
        rewardsMultiplierBlocks[3] = 400;
        uint64[] memory rewardsMultipliers = new uint64[](4);
        rewardsMultipliers[0] = 100;
        rewardsMultipliers[1] = 50;
        rewardsMultipliers[2] = 25;
        rewardsMultipliers[3] = 10;

        // WithdrawFees
        uint64[] memory withdrawFeeBlocks = new uint64[](4);
        withdrawFeeBlocks[0] = 0;
        withdrawFeeBlocks[1] = 100;
        withdrawFeeBlocks[2] = 1000;
        withdrawFeeBlocks[3] = 10_000;
        uint64[] memory withdrawFees = new uint64[](4);
        withdrawFees[0] = 15;
        withdrawFees[1] = 10;
        withdrawFees[2] = 5;
        withdrawFees[3] = 2;

        pool =
        new Pool(address(token1), deployer, 20, 10, rewardsMultiplierBlocks, rewardsMultipliers, withdrawFeeBlocks, withdrawFees, address(boosterPack));

        assertEq(pool.getBaseRateTokensPerBlock(), 20);
        assertEq(pool.getDepositFee(), 10);
        assertEq(pool.getDepositFeeRecipient(), deployer);
        assertEq(pool.getRewardsMultiplierBlockNumber(0), 100);
        assertEq(pool.getRewardsMultiplierBlockNumber(1), 200);
        assertEq(pool.getRewardsMultiplierBlockNumber(2), 300);
        assertEq(pool.getRewardsMultiplierBlockNumber(3), 400);
        assertEq(pool.getRewardsMultiplier(0), 100);
        assertEq(pool.getRewardsMultiplier(1), 50);
        assertEq(pool.getRewardsMultiplier(2), 25);
        assertEq(pool.getRewardsMultiplier(3), 10);
        assertEq(pool.getWithdrawFeeBlockNumber(0), 0);
        assertEq(pool.getWithdrawFeeBlockNumber(1), 100);
        assertEq(pool.getWithdrawFeeBlockNumber(2), 1000);
        assertEq(pool.getWithdrawFeeBlockNumber(3), 10_000);
        assertEq(pool.getWithdrawFee(0), 15);
        assertEq(pool.getWithdrawFee(1), 10);
        assertEq(pool.getWithdrawFee(2), 5);
        assertEq(pool.getWithdrawFee(3), 2);
    }

    function test_addRewardsMultiplier_fuzz(uint32 blockNumber_, uint32 multiplier_) public {
        vm.assume(blockNumber_ > 0);
        vm.assume(multiplier_ > 0);
        
        vm.startPrank(deployer);

        pool.addRewardsMultiplier(blockNumber_, multiplier_);
        assertEq(pool.getRewardsMultiplierBlockNumber(4), blockNumber_);
        assertEq(pool.getRewardsMultiplier(4), multiplier_);

        vm.stopPrank();
    }

    function test_updateRewardsMultiplier_fuzz(uint32 blockNumber_, uint32 multiplier_) public {
        vm.assume(blockNumber_ > 0);
        vm.assume(multiplier_ > 0);

        vm.startPrank(deployer);

        pool.updateRewardsMultiplier(0, blockNumber_, multiplier_);
        assertEq(pool.getRewardsMultiplierBlockNumber(0), blockNumber_);
        assertEq(pool.getRewardsMultiplier(0), multiplier_);

        vm.stopPrank();
    }

    function test_addWithdrawFee_fuzz(uint32 blockNumber_, uint32 fee_) public {
        vm.assume(blockNumber_ > 0);
        vm.assume(fee_ > 0);
        
        vm.startPrank(deployer);

        pool.addWithdrawFee(blockNumber_, fee_);
        assertEq(pool.getWithdrawFeeBlockNumber(4), blockNumber_);
        assertEq(pool.getWithdrawFee(4), fee_);

        vm.stopPrank();
    }

    function test_updateWithdrawFee_fuzz(uint32 blockNumber_, uint32 fee_) public {
        vm.assume(blockNumber_ > 0);
        vm.assume(fee_ > 0);
        
        vm.startPrank(deployer);

        pool.updateWithdrawFee(0, blockNumber_, fee_);
        assertEq(pool.getWithdrawFeeBlockNumber(0), blockNumber_);
        assertEq(pool.getWithdrawFee(0), fee_);

        vm.stopPrank();
    }

    function test_deposit_fuzz(uint128 amount_) public {  
        vm.startPrank(deployer);

        uint128 depositFee_ = pool.getDepositFee();

        vm.stopPrank();

        amount_ = uint128(bound(amount_, 1, uint128(amount_ * (depositFee_ / 1000))));
        
        vm.startPrank(userFuzz);

        token1.mint(userFuzz, amount_);
        token1.approve(address(pool), amount_);

        uint256 balanceUserBefore = token1.balanceOf(userFuzz);
        uint256 balancePoolBefore = token1.balanceOf(address(pool));
        uint256 balanceDeployerBefore = token1.balanceOf(deployer);

        pool.deposit(amount_);

        vm.stopPrank();

        vm.startPrank(deployer);

        uint128 totalFee_ = uint128(depositFee_ * 1000 / 100);
        uint128 depositedAmount_ = uint128(amount_ - ((amount_ * depositFee_) / 1000));

        assertLe(token1.balanceOf(userFuzz), balanceUserBefore);
        assertGe(token1.balanceOf(address(pool)), balancePoolBefore);
        assertGe(token1.balanceOf(deployer), balanceDeployerBefore);

        assertEq(token1.balanceOf(userFuzz), 0);
        assertLe(token1.balanceOf(address(pool)), depositedAmount_);
        assertGe(token1.balanceOf(deployer), amount_ - depositedAmount_);

        assertEq(pool.getUserAccumRewards(userFuzz), 0);
        assertEq(pool.getUserAccumRewardsBP(userFuzz), 0);
        assertEq(pool.getUserClaimableRewardsBP(userFuzz), 0);
        assertLe(pool.getUserTotalAmountDeposited(userFuzz), depositedAmount_);
        assertEq(pool.getUserActiveBoosterPack(userFuzz), 0);
        assertEq(pool.getUserNextDepositIdToRemove(userFuzz), 0);
        assertEq(pool.getUserDepositBlockNumber(userFuzz, 0), block.number);
        assertLe(pool.getUserDepositAmount(userFuzz, 0), depositedAmount_);

        vm.stopPrank();
    }

    function test_withdraw_fuzz(uint128 _amountW) public {
        // Set up
        vm.startPrank(deployer);

        uint128 depositFee_ = pool.getDepositFee() * 1000 / 100;
        uint128 amountD_ = 50000;

        uint128 amountDepositFee_ = (amountD_ * depositFee_) / 1000;
        _amountW = uint128(bound(_amountW, 1, uint128(amountD_ - amountDepositFee_)));

        vm.stopPrank();

        vm.startPrank(userFuzz);

        token1.mint(userFuzz, amountD_);
        token1.approve(address(pool), amountD_);
        pool.deposit(amountD_);

        uint256 balanceUserBefore = token1.balanceOf(userFuzz);
        uint256 balancePoolBefore = token1.balanceOf(address(pool));
        uint256 balanceDeployerBefore = token1.balanceOf(deployer);

        pool.withdraw(_amountW);

        vm.stopPrank();

        vm.startPrank(deployer);

        assertGe(token1.balanceOf(userFuzz), balanceUserBefore);
        assertLe(token1.balanceOf(address(pool)), balancePoolBefore);
        assertGe(token1.balanceOf(deployer), balanceDeployerBefore);

        vm.stopPrank();
    }

    function test_claimRewards() public {
        // Set up
        vm.startPrank(user1);

        token1.approve(address(pool), 500);
        pool.deposit(500);
        vm.roll(50);
        pool.claimRewards(user1);

        vm.stopPrank();

        vm.startPrank(deployer);

        assertEq(token1.balanceOf(user1), 98_499);
        assertEq(token1.balanceOf(address(pool)), 450);
        assertEq(token1.balanceOf(deployer), 50);

        assertEq(pool.getRewardsPerToken(), 217_777);
        assertEq(pool.getLastBlockUpdated(), 50);
        assertEq(pool.getUserAccumRewards(user1), 97_999);
        assertEq(pool.getUserAccumRewardsBP(user1), 0);
        assertEq(pool.getUserClaimableRewardsBP(user1), 0);
        assertEq(pool.getUserTotalAmountDeposited(user1), 450);

        vm.stopPrank();
    }


    function test_burnBP() public {
        // Set up
        vm.startPrank(deployer);

        boosterPack.addWhitelistedAddrBP(deployer);
        boosterPack.addWhitelistedAddrBP(address(pool));
        boosterPack.mint(user1, 1, 2, 50, 100, 3);
        boosterPack.mint(user1, 2, 1, 50, 200, 3);

        vm.stopPrank();

        vm.startPrank(user1);

        // Unhappy path Nº1 - Trying to burn a BoosterPack that does not exist.
        vm.expectRevert(abi.encodeWithSignature("Pool_BPDoesNotExistBPError()"));
        pool.burnBP(3);

        // Unhappy path Nº2 - Trying to burn a BoosterPack that has already expired.
        vm.roll(150);
        vm.expectRevert(abi.encodeWithSignature("Pool_ExpiredBPError()"));
        pool.burnBP(1);

        // Happy path - BoosterPack exists, not expired and the user does not have an active BP.
        boosterPack.setApprovalForAll(address(pool), true);
        pool.burnBP(2);

        // Unhappy path Nº3 - Trying to burn a BoosterPack when the user has already one active.
        vm.expectRevert(abi.encodeWithSignature("Pool_OnlyOneActiveBPError()"));
        pool.burnBP(1);

        vm.stopPrank();

        vm.startPrank(deployer);

        assertEq(pool.getUserActiveBoosterPack(user1), 2);

        vm.stopPrank();
    }

    function test_pausePool() public {
        // Unhappy path Nº1 - Trying to pause the Pool without being the Owner.
        vm.startPrank(user1);

        vm.expectRevert("Ownable: caller is not the owner");
        pool.pause();

        vm.stopPrank();

        // Happy path - Being the Owner
        vm.startPrank(deployer);

        pool.pause();
        assertEq(pool.getPaused(), true);

        vm.stopPrank();
    }

    function test_unpausePool() public {
        // Set up
        vm.startPrank(deployer);

        pool.pause();

        vm.stopPrank();

        // Unhappy path Nº1 - Trying to unpause the Pool without being the Owner.
        vm.startPrank(user1);

        vm.expectRevert("Ownable: caller is not the owner");
        pool.unpause();

        vm.stopPrank();

        // Happy path - Being the Owner
        vm.startPrank(deployer);

        pool.unpause();
        assertEq(pool.getPaused(), false);

        vm.stopPrank();
    }
}

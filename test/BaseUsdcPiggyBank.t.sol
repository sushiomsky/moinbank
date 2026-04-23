// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {BaseUsdcPiggyBank} from "../src/BaseUsdcPiggyBank.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseUsdcPiggyBankTest is Test {
    BaseUsdcPiggyBank public piggyBank;
    IERC20 public constant USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    
    address public beneficiary = address(0xBA5E);
    address public user = address(0x1337);
    
    uint256 public targetAmount = 1000 * 1e6; // 1000 USDC
    uint256 public unlockTime;

    function setUp() public {
        // Fork Base mainnet to use real USDC address
        string memory rpc = vm.envOr("BASE_RPC_URL", string("https://mainnet.base.org"));
        vm.createSelectFork(rpc);

        unlockTime = block.timestamp + 7 days;
        
        piggyBank = new BaseUsdcPiggyBank(
            beneficiary,
            targetAmount,
            unlockTime
        );

        // Give user some USDC
        deal(address(USDC), user, 10_000 * 1e6);
        
        vm.startPrank(user);
        USDC.approve(address(piggyBank), type(uint256).max);
        vm.stopPrank();
    }

    function test_DepositWithoutRelease() public {
        uint256 depositAmt = 500 * 1e6;
        
        vm.prank(user);
        piggyBank.deposit(depositAmt);
        
        assertEq(piggyBank.totalDeposited(), depositAmt);
        assertEq(USDC.balanceOf(address(piggyBank)), depositAmt);
        assertFalse(piggyBank.isReleased());
    }

    function test_DepositTriggersReleaseTargetReached() public {
        uint256 depositAmt = 1000 * 1e6;
        uint256 balanceBefore = USDC.balanceOf(beneficiary);

        vm.prank(user);
        piggyBank.deposit(depositAmt);

        assertTrue(piggyBank.isReleased());
        assertEq(USDC.balanceOf(beneficiary), balanceBefore + depositAmt);
        assertEq(USDC.balanceOf(address(piggyBank)), 0);
    }

    function test_DepositTriggersReleaseTimePassed() public {
        uint256 depositAmt = 100 * 1e6;
        uint256 balanceBefore = USDC.balanceOf(beneficiary);

        // Warp time past unlock
        vm.warp(unlockTime + 1);

        vm.prank(user);
        piggyBank.deposit(depositAmt);

        assertTrue(piggyBank.isReleased());
        assertEq(USDC.balanceOf(beneficiary), balanceBefore + depositAmt);
    }

    function test_RevertDepositAfterRelease() public {
        // Trigger release first
        vm.prank(user);
        piggyBank.deposit(targetAmount);
        
        assertTrue(piggyBank.isReleased());

        // Try to deposit again
        vm.expectRevert(BaseUsdcPiggyBank.AlreadyReleased.selector);
        vm.prank(user);
        piggyBank.deposit(1e6);
    }

    function test_RevertZeroDeposit() public {
        vm.expectRevert(BaseUsdcPiggyBank.ZeroDeposit.selector);
        vm.prank(user);
        piggyBank.deposit(0);
    }

    function test_ConstructorReverts() public {
        // Invalid beneficiary
        vm.expectRevert(BaseUsdcPiggyBank.InvalidBeneficiary.selector);
        new BaseUsdcPiggyBank(address(0), 100e6, block.timestamp + 1);

        // Invalid target
        vm.expectRevert(BaseUsdcPiggyBank.InvalidTarget.selector);
        new BaseUsdcPiggyBank(beneficiary, 0, block.timestamp + 1);

        // Invalid unlock time
        vm.expectRevert(BaseUsdcPiggyBank.InvalidUnlockTime.selector);
        new BaseUsdcPiggyBank(beneficiary, 100e6, block.timestamp);
    }
}

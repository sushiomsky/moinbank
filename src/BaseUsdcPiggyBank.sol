// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title BaseUsdcPiggyBank
 * @notice A minimal savings contract for USDC on Base.
 * @dev Funds are released automatically when a deposit hits the target amount or the unlock time passes.
 */
contract BaseUsdcPiggyBank {
    using SafeERC20 for IERC20;

    // --- Configuration (Immutable) ---
    IERC20 public constant USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    address public immutable BENEFICIARY;
    uint256 public immutable TARGET_AMOUNT;
    uint256 public immutable UNLOCK_TIMESTAMP;

    // --- State ---
    uint256 public totalDeposited;
    bool public isReleased;

    // --- Errors ---
    error InvalidBeneficiary();
    error InvalidTarget();
    error InvalidUnlockTime();
    error ZeroDeposit();
    error AlreadyReleased();
    error NothingToRelease();

    // --- Events ---
    event Deposited(address indexed sender, uint256 amount);
    event Released(address indexed beneficiary, uint256 amount);

    /**
     * @param _beneficiary Address that will receive funds on release.
     * @param _targetAmount Cumulative amount of USDC (6 decimals) required to trigger release.
     * @param _unlockTimestamp Unix timestamp after which any deposit triggers release.
     */
    constructor(address _beneficiary, uint256 _targetAmount, uint256 _unlockTimestamp) {
        if (_beneficiary == address(0)) revert InvalidBeneficiary();
        if (_targetAmount == 0) revert InvalidTarget();
        if (_unlockTimestamp <= block.timestamp) revert InvalidUnlockTime();

        BENEFICIARY = _beneficiary;
        TARGET_AMOUNT = _targetAmount;
        UNLOCK_TIMESTAMP = _unlockTimestamp;
    }

    /**
     * @notice Deposit USDC into the piggy bank.
     * @dev Release happens automatically if conditions are met after this deposit.
     * @param amount The amount of USDC to deposit (6 decimals).
     */
    function deposit(uint256 amount) external {
        if (isReleased) revert AlreadyReleased();
        if (amount == 0) revert ZeroDeposit();

        // 1. Pull USDC from sender
        USDC.safeTransferFrom(msg.sender, address(this), amount);
        totalDeposited += amount;

        emit Deposited(msg.sender, amount);

        // 2. Check for release condition
        if (totalDeposited >= TARGET_AMOUNT || block.timestamp >= UNLOCK_TIMESTAMP) {
            _release();
        }
    }

    /**
     * @notice Manually trigger the release if conditions are met.
     * @dev Useful if funds were sent directly via transfer() or time has passed.
     */
    function release() external {
        if (isReleased) revert AlreadyReleased();
        if (totalDeposited < TARGET_AMOUNT && block.timestamp < UNLOCK_TIMESTAMP) {
            revert NothingToRelease();
        }
        _release();
    }

    /**
     * @dev Internal function to handle the actual transfer of funds to the beneficiary.
     */
    function _release() internal {
        uint256 balance = USDC.balanceOf(address(this));
        if (balance == 0) revert NothingToRelease();

        isReleased = true;
        USDC.safeTransfer(BENEFICIARY, balance);

        emit Released(BENEFICIARY, balance);
    }
}

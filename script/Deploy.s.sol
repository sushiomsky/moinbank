// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {BaseUsdcPiggyBank} from "../src/BaseUsdcPiggyBank.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address beneficiary = vm.envAddress("BENEFICIARY");
        uint256 targetAmountUsdc = vm.envUint("TARGET_USDC_6");
        uint256 unlockTimestamp = vm.envUint("UNLOCK_TIMESTAMP");

        vm.startBroadcast(deployerPrivateKey);

        BaseUsdcPiggyBank piggyBank = new BaseUsdcPiggyBank(
            beneficiary,
            targetAmountUsdc,
            unlockTimestamp
        );

        console2.log("BaseUsdcPiggyBank deployed at:", address(piggyBank));

        vm.stopBroadcast();
    }
}

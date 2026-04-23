# 🐷 OINK BASE: The Serverless USDC Piggy Bank

**OINK BASE** is a production-ready, serverless decentralized application (dApp) that allows anyone to create a private USDC savings vault on the **Base** network. 

Unlike traditional savings accounts, OINK BASE is entirely non-custodial, serverless, and enforced by smart contract logic. Your funds are locked until your goal is met or your time is up—no middleman, no fees, just code.

---

## 🚀 Key Features

- **Self-Governing Savings**: Funds are automatically released to the beneficiary only when the target amount is reached OR the lock duration expires.
- **Serverless Dashboard**: A single-file HTML dashboard (`dashboard.html`) that interacts directly with the blockchain via MetaMask. No backend required.
- **Base Network Native**: Built for Base, offering ultra-low transaction fees and fast confirmation times.
- **Non-Custodial**: You (or your designated beneficiary) are the only ones who can ever touch the funds.
- **MetaMask Integrated**: Seamless deployment and management directly from your browser.

---

## 🛠 Tech Stack

- **Smart Contracts**: Solidity 0.8.24 (Foundry)
- **Frontend**: Vanilla HTML5, CSS3 (Glassmorphism), and JavaScript
- **Blockchain Library**: Ethers.js v6
- **Network**: Base Mainnet (Chain ID: 8453)
- **Asset**: USDC (Native Base USDC)

---

## 📖 User Manual

### 1. Opening the Dashboard
Simply open the `dashboard.html` file in any modern web browser with a web3 wallet (like MetaMask or Coinbase Wallet) installed.

### 2. Connecting Your Wallet
- Click **"Connect Wallet"** in the top right.
- Ensure your wallet is switched to the **Base Mainnet**. If not, the dashboard will prompt you to switch or add the network automatically.

### 3. Deploying a New Piggy Bank
Navigate to the **"Deploy New"** tab:
- **Beneficiary Address**: The wallet address that will receive the funds once unlocked.
- **Target Goal (USDC)**: The amount of USDC you want to save.
- **Lock Duration (Days)**: The minimum number of days the funds should be locked (acts as a "fail-safe" unlock if the goal isn't met).
- Click **"Deploy via MetaMask"**. Once the transaction confirms, you will receive a unique contract address.

### 4. Tracking & Depositing
Navigate to the **"Track Existing"** tab:
- Enter your **Contract Address**.
- View your progress bar, current balance, and target.
- Click **"Deposit USDC"** to add funds to your piggy bank.
- **Note**: The first deposit will require a USDC "Approve" transaction before the "Deposit" transaction.

### 5. Automatic Release
The contract follows strict "Piggy Bank" logic:
- If `Total Deposited >= Target Amount`, the contract **automatically** sends the entire balance to the Beneficiary.
- If `Current Time >= Unlock Timestamp`, the next deposit (even a tiny one) will trigger the release of all funds to the Beneficiary.

---

## 💻 Developer Guide

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed.
- A private key and RPC URL for Base.

### Contract Interaction
The core logic resides in `src/BaseUsdcPiggyBank.sol`. 

**Build:**
```bash
forge build
```

**Test:**
```bash
forge test
```

**Deploy via CLI:**
```bash
forge script script/Deploy.s.sol --rpc-url <BASE_RPC_URL> --broadcast --verify
```

### Dashboard Customization
The `dashboard.html` is designed to be standalone. If you update the smart contract, make sure to update the `BYTECODE` constant and `PIGGY_ABI` in the `<script>` section of the HTML file.

---

## 🔒 Security Considerations

- **Immutability**: Once a Piggy Bank is deployed, the Beneficiary, Target, and Unlock Time are **immutable**. They cannot be changed by anyone, including the creator.
- **USDC Only**: This specific version is hardcoded to support only the official Circle USDC on Base (`0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`). Do not send other tokens to the contract address.
- **Audit**: This code is provided as a demonstration and has not been formally audited. Use at your own risk.

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information (if applicable).

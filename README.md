# SkillChain 🎓⛓️

> **Decentralized Professional Portfolio Registry on Ethereum Blockchain**

![Solidity](https://img.shields.io/badge/Solidity-0.8.x-363636?style=for-the-badge&logo=solidity)
![Network](https://img.shields.io/badge/Network-Sepolia_Testnet-627EEA?style=for-the-badge&logo=ethereum)
![Status](https://img.shields.io/badge/Status-Deployed_&_Verified-10B981?style=for-the-badge)

---

## 📌 Overview

SkillChain is a decentralized on-chain portfolio registry where professionals can register their work, earn NFT skill badges, build a tamper-proof reputation score, and monetize their knowledge — all without any centralized platform.

This project demonstrates real-world application of Ethereum smart contracts, IPFS decentralized storage, and Web3 identity systems.

---

## 🚨 The Problem

Today, professionals rely on centralized platforms like LinkedIn, GitHub, and Kaggle to showcase their work. These platforms create serious problems:

| Problem | Description |
|---|---|
| 🎭 **Credential Fraud** | Degrees and project claims on resumes are easily fabricated with no tamper-proof verification |
| 🏢 **Centralized Ownership** | Platforms own all user data. Account bans erase years of professional history overnight |
| 📅 **No Proof of Prior Art** | No immutable, timestamped record of when work was first created |
| 💸 **Hiring Intermediaries** | Freelance platforms charge 10–20% fees with no trustless alternative |
| 🔒 **Siloed Reputation** | GitHub stars, Kaggle rankings, and LinkedIn endorsements are all isolated |

---

## ✅ The Solution — SkillChain

SkillChain replaces all of this with a single smart contract on the Ethereum blockchain:

- 📁 **On-Chain Portfolio Registry** — Register projects with IPFS hash + immutable timestamp proof
- 🏅 **Automatic NFT Skill Badges** — Every project registration auto-mints a soulbound NFT badge
- 💰 **Token-Gated Premium Access** — Monetize your work directly with zero platform fee
- ⭐ **On-Chain Reputation Score** — Portable, tamper-proof, publicly readable reputation

---

## 🏗️ System Architecture

```
👤 Professional (MetaMask)
        │
        ▼ 1. registerProject()
📁 Upload to IPFS (Pinata)
        │
        ▼ 2. IPFS CID returned
⚙️ SkillChain Smart Contract (Solidity 0.8.x)
        │
        ├──▶ ⛓️ Ethereum Blockchain (Sepolia) — Hash + Timestamp stored
        │
        ├──▶ 🏅 Auto-mint NFT Skill Badge (Soulbound)
        │
        └──▶ ⭐ Reputation Score +10 pts
                │
                ▼ 6. Portfolio + Badge + Score returned to Professional
```

---

## 📄 Smart Contract Details

| Field | Value |
|---|---|
| **Contract Name** | SkillChain |
| **Language** | Solidity 0.8.x |
| **Network** | Ethereum Sepolia Testnet |
| **Contract Address** | `0x172DC774504401B19de93DDe053002B70833E66f` |
| **Compiler** | 0.8.31+commit.fd3a2265 |
| **Verification** | ✅ Sourcify \| ✅ Blockscout \| ✅ Routescan |

🔗 **[View on Sepolia Etherscan](https://sepolia.etherscan.io/address/0x172DC774504401B19de93DDe053002B70833E66f)**

---

## 🔧 Core Functions

### Write Functions (require gas)

| Function | Access | Description |
|---|---|---|
| `registerProject()` | Public | Register a project on-chain. Auto-mints NFT badge. Adds +10 reputation. |
| `accessPremiumProject()` | Public (payable) | Pay ETH to unlock premium project IPFS hash. CEI pattern used. |
| `endorseProject()` | Admin only | Admin verifies a project. Adds +50 reputation to creator. |
| `pauseContract()` | Admin only | Emergency stop for all write operations. |

### View Functions (free — no gas)

| Function | Description |
|---|---|
| `getUserPortfolio(address)` | Returns all project IDs for a wallet |
| `getReputation(address)` | Returns reputation score for any wallet |
| `getProject(uint256)` | Returns full project details |
| `getPlatformStats()` | Returns total projects and total badges |
| `getUserBadges(address)` | Returns all NFT badge IDs for a wallet |

---

## 🏛️ Data Structures

```solidity
struct Project {
    uint256 id;           // Unique auto-incremented ID
    address owner;        // Wallet address of creator
    string  ipfsHash;     // IPFS CID pointing to the actual file
    string  title;        // Project name
    string  category;     // Skill domain: Web3, ML, Research...
    uint256 timestamp;    // block.timestamp — immutable proof of creation
    bool    isPremium;    // Paid access flag
    uint256 accessPrice;  // Cost in wei for premium access
    bool    isVerified;   // Admin endorsement status
}

struct SkillBadge {
    uint256 tokenId;      // Unique NFT badge ID
    address recipient;    // Badge holder wallet
    string  category;     // Skill the badge represents
    uint256 issuedAt;     // Minting timestamp
}

struct UserProfile {
    bool    exists;           // First-time registration flag
    uint256 reputationScore;  // Cumulative on-chain score
    uint256 projectsCount;    // Total projects registered
    uint256 badgesEarned;     // Total NFT badges received
}
```

---

## ⭐ Reputation System

| Action | Points | Reason |
|---|---|---|
| Register a project | +10 | Base contribution reward |
| Receive admin endorsement | +50 | Quality signal — 5x weight |
| Access premium content | +2 | Rewards knowledge consumption |

---

## 🔐 Security Features

| Feature | Implementation |
|---|---|
| **Reentrancy Prevention** | Check-Effects-Interaction (CEI) pattern in `accessPremiumProject()` |
| **Access Control** | `onlyOwner` modifier for all admin functions |
| **Emergency Stop** | `pauseContract()` circuit breaker |
| **Overflow Protection** | Solidity 0.8.x built-in arithmetic protection |
| **Input Validation** | `require()` statements on all public inputs |
| **Soulbound NFTs** | No `transferFrom()` — badges permanently tied to earning wallet |

---

## 🚀 How to Deploy

### Prerequisites
- [MetaMask](https://metamask.io/) browser extension installed
- Sepolia testnet selected in MetaMask
- At least 0.05 SepoliaETH (get free from [Google Cloud Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia))
- [Remix IDE](https://remix.ethereum.org/) open in browser

### Step 1 — Setup MetaMask
1. Open MetaMask → Switch to **Ethereum Sepolia** network
2. Get free SepoliaETH from Google Cloud Web3 Faucet
3. Confirm balance shows > 0.01 SepoliaETH

### Step 2 — Compile in Remix
1. Go to [remix.ethereum.org](https://remix.ethereum.org)
2. Create new file → name it `SkillChain.sol`
3. Paste the complete contract code from `/contracts/SkillChain.sol`
4. Click **Solidity Compiler** tab → set version to `0.8.20`
5. Click **Compile SkillChain.sol**
6. Confirm ✅ green tick — zero errors, zero warnings

### Step 3 — Deploy
1. Click **Deploy & Run Transactions** tab
2. Change Environment to **Injected Provider - MetaMask**
3. MetaMask popup → click **Connect**
4. Confirm network shows **Sepolia**
5. Click orange **Deploy** button
6. MetaMask confirmation popup → click **Confirm**
7. Wait 20–30 seconds for transaction to mine
8. Contract address appears in **Deployed Contracts** panel ✅

### Step 4 — Test Functions
Follow this order for testing:

```
1. registerProject("QmHash123", "My Project", "Web3", false, 0)
2. getPlatformStats()               → returns (1, 1)
3. getUserPortfolio(your_wallet)    → returns [1]
4. getReputation(your_wallet)       → returns 10
5. endorseProject(1)                → admin only
6. getReputation(your_wallet)       → returns 60
```

---

## 📊 Gas Usage

| Operation | Approx Gas | Cost (Sepolia) |
|---|---|---|
| Contract Deployment | ~1,200,000 | One-time only |
| `registerProject()` | ~150,000 | Per project |
| `endorseProject()` | ~60,194 | Admin action |
| `accessPremiumProject()` | ~80,000 | Per access |
| All view functions | **0** | Always free |

---


## 🌐 Live Deployment

The contract is **live and verified** on Ethereum Sepolia Testnet.

| Explorer | Link | Status |
|---|---|---|
| Sepolia Etherscan | [View Contract](https://sepolia.etherscan.io/address/0x172DC774504401B19de93DDe053002B70833E66f) | ✅ Verified |
| Sourcify | Verified | ✅ |
| Blockscout | Verified | ✅ |
| Routescan | Verified | ✅ |

---

## 🔮 Future Scope

- **DAO Governance** — Token holders vote on platform parameters and endorsements
- **Escrow-Based Hiring** — Trustless P2P payments for freelance work
- **Layer-2 Deployment** — Deploy on Polygon/Optimism for near-zero gas fees
- **Cross-Chain NFT Badges** — Badges interoperable across multiple blockchains
- **ZK-Proof Private Portfolios** — Prove credentials without revealing sensitive data

---

## 🛠️ Tech Stack

![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=flat-square&logo=ethereum&logoColor=white)
![Solidity](https://img.shields.io/badge/Solidity-363636?style=flat-square&logo=solidity&logoColor=white)
![IPFS](https://img.shields.io/badge/IPFS-65C2CB?style=flat-square&logo=ipfs&logoColor=white)
![MetaMask](https://img.shields.io/badge/MetaMask-F6851B?style=flat-square&logo=metamask&logoColor=white)

| Layer | Technology |
|---|---|
| Smart Contract | Solidity 0.8.x |
| IDE | Remix IDE |
| Wallet | MetaMask |
| Testnet | Ethereum Sepolia |
| File Storage | IPFS via Pinata |
| Explorer | Sepolia Etherscan |

---

<div align="center">

**Built with ❤️ on Ethereum Blockchain**

*SkillChain — Own Your Skills. Prove Your Work. Build Your Reputation.*

</div>

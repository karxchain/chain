# KARX Token Contract

This directory contains the source code for the **KARX Token (KARX)** — the official utility and governance token powering the KARX blockchain infrastructure for Digital Product Passports (DPP).

## 🪙 Token Overview

| Property          | Value                                                  |
|------------------|---------------------------------------------------------|
| **Token Name**    | KARX Token                                             |
| **Symbol**        | KARX                                                   |
| **Total Supply**  | 1,000,000,000 KARX                                     |
| **Decimals**      | 18                                                     |
| **Deployed On**   | [XDC Mainnet](https://explorer.xinfin.network/)        |
| **Contract Address** | 0x8f864122aec1908855ce9bAB1bd46356c2372237          |
| **License**       | MIT                                                    |

## 🔐 Features

- ✅ ERC20-compliant
- 🔒 Pausable by owner (pre-TGE and emergency controls)
- 🔥 Transfer-based burn mechanism (configurable)
- 💸 Configurable transaction fee with destination wallet
- 🛡️ Anti-whale mechanism (transfer & wallet cap)
- 🧾 Gasless approvals via EIP-2612 (`ERC20Permit`)
- 🔁 Ownership and exclusion controls for launchpads & exchanges

## 📂 File Structure

contracts/
└── token/
    ├── KARXToken.sol         # Main token logic (v1.0.0)
    └── README.md             # This file

## 🧪 Deployment Details

| Network      | Deployed From                              | Tx Hash                                                            | Date       |
|--------------|--------------------------------------------|----------------|---------------------------------------------------|------------|
| XDC Mainnet  | 0x599F6202390A37b820FC8BDc2Fb9792A71e1D15c | 0x07926f3b4e508a5d7879497c17d5031c94a64e3da72e6c3e7ee14d47a7233dc0 | YYYY-MM-DD |

> 🔎 Full deployment details available in `../deployments/mainnet/KARX_deploy_details.md`

## 📜 Verification

- [Contract Source Code Verified](https://explorer.xinfin.network/contract-verification)
- Compiler: `0.8.20`
- Optimization: Enabled

## 📘 Related Docs

- [Tokenomics PDF](../../docs/KARX_Tokenomics.pdf)...coming soon
- [KARX Protocol Whitepaper](https://karx.org/whitepaper)...coming soon

## 🧑‍💻 License

This project is licensed under the [MIT License](../../LICENSE).

---

© 2021–2025 KARX Chain — Empowering Digital Product Passports

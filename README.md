# 📦 Skeletor Labs - Smart Contracts

Welcome to the public Skeletor Labs smart contracts repo -- built with [Foundry](https://github.com/foundry-rs/foundry) — a blazing-fast, modular toolkit for Ethereum development. This repo contains auditable, tested, and gas-efficient contracts written in Solidity.

## ✨ Contracts

### ✅ TestimonialRegistry

A simple and gas-efficient registry for storing testimonials off-chain (on IPFS) while keeping verifiable references on-chain. It includes:

- IPFS CID **storage and mapping**
- **Deactivation** by Author/Owner
- **Like** functionality (one like per address/testimonial)
- Public **event logging** for off-chain indexing

Planned features:

- More contracts coming soon...

## 🛠 Stack

- **Solidity**: Smart contract language
- **Foundry**: Rust-based Ethereum toolkit
  - `forge`: Build, test, and deploy contracts
  - `anvil`: Local development EVM
  - `cast`: Interact with deployed contracts
- **OpenZeppelin**: Industry-standard libraries
- **IPFS (optional)**: Off-chain content addressing

---

## 🧪 Getting Started

Make sure you have [Foundry installed](https://book.getfoundry.sh/getting-started/installation.html):

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

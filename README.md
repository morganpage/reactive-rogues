##


## The Contracts

### Streak System
The streak system contract is designed to implement a standard streak system that you often find in many games (Outmine), apps (Duolingo) and quest systems (Zealy). A streak system encourages users to participate regularly to increase their streak earning more points and optionally receiving NFT gifts when certain streak milestones are met. If a user doesn't claim within the streakResetTime they will go back to streak 1 (this can be turned off by setting streakResetTime to 0).

Example:
```code
setPointMilestone(1,10)
setPointMilestone(5,50)
setTokenMilestone(1,13)
setTokenMilestone(10,14)
```
With the above set, on the 1st claim (streak 1), the user would receive 10 points and an NFT with a tokenId of 13. On the 2nd claim (streak 2) they would get another 10 points bringing the total to 20 but no additional NFT. For streaks 3 and 4 they would still get 10 points but on streak 5 they would start to get 50 points and streak 10 they would get an NFT with a tokenId of 14.

Although the NFT rewards are defined in the Streak System contract, the actually minting is done via the [Reactive Network](https://reactive.network/). The Streak System Contract emits an EarnedNFT event that


## Testnet Deployment
```
4 Contracts need to be deployed: (replace below addresses with your own as you deploy)
StreakSystem - Reactive - 0xFc070cB5B8fefB6FF487F0f3d9a06c8C89A90700
StreakSystemReactive - Reactive - 0xB66B88C72D09A1af2A53467546431E5578B7F009
MintNFTCallback - Ethereum - 0xb72ce7F273Ea8b6730E2E1fB10B0b3D558Bd07ea
RoguesItems - Ethereum - 0x8897167068573d6228Ee8eC62E9DCCEeD193f89F
```

```bash
DESTINATION_RPC=https://ethereum-sepolia-rpc.publicnode.com

forge create --broadcast --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/RoguesItems.sol:RoguesItems


REACTIVE_RPC=https://kopli-rpc.rnk.dev

forge create --legacy --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/StreakSystem.sol:StreakSystem

# Below is specified in docs
DESTINATION_CALLBACK_PROXY_ADDR=0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA
# The deployed address of the RoguesItems contract
ERC1155_ADDR=0x8897167068573d6228Ee8eC62E9DCCEeD193f89F

forge create --broadcast --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/MintNFTCallback.sol:MintNFTCallback --value 0.05ether --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR $ERC1155_ADDR

SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000fffFfF
REACTIVE_CHAIN_ID=5318008
DESTINATION_CHAIN_ID=11155111
# The deployed address of the StreakSystem contract
ORIGIN_ADDR=0xFc070cB5B8fefB6FF487F0f3d9a06c8C89A90700
# The deployed address of the MintNFTCallback contract
CALLBACK_ADDR=0xb72ce7F273Ea8b6730E2E1fB10B0b3D558Bd07ea

forge create --legacy --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/StreakSystemReactive.sol:StreakSystemReactive --value 0.01ether --constructor-args $SYSTEM_CONTRACT_ADDR $REACTIVE_CHAIN_ID $DESTINATION_CHAIN_ID $ORIGIN_ADDR $CALLBACK_ADDR

forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID $ORIGIN_ADDR StreakSystem

forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID 0xB66B88C72D09A1af2A53467546431E5578B7F009 StreakSystemReactive

forge verify-contract --chain-id $DESTINATION_CHAIN_ID $CALLBACK_ADDR --etherscan-api-key $ETHERSCAN_API_KEY MintNFTCallback

forge verify-contract --chain-id $DESTINATION_CHAIN_ID $ERC1155_ADDR --etherscan-api-key $ETHERSCAN_API_KEY RoguesItems


```
## Testnet deployment
Streak System deployment on Kopli:

https://kopli.reactscan.net/tx/0xfd73f99cf2d3814de42d9b0a4c310da3d3233541456f931159c6a1188ea444d8

## Interacting

```bash
cast call $ORIGIN_ADDR "streakIncrementTime()(uint256)" --rpc-url $REACTIVE_RPC

cast call $ORIGIN_ADDR "streak(address)(uint256)" 0xb2F9531bfe0C742135C7D3ad9038d298616a65A9 --rpc-url $REACTIVE_RPC

#Grant the minter role to the MintNFTCallback contract
cast send $ERC1155_ADDR "grantMinterRole(address)" $CALLBACK_ADDR --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY

#Below doesn't work atm you will need to do this in Remix
cast send $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 1 13 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

cast send $ORIGIN_ADDR "setStreakResetTime(uint256)" 1 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

cast send $ORIGIN_ADDR "claim()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

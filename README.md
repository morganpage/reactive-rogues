# A Fully On-Chain Streak System with NFT Minting using Reactive Contracts


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

Although the NFT rewards are defined in the Streak System contract, the actually minting is done via the [Reactive Network](https://reactive.network/). The Streak System Contract emits an EarnedNFT event that is subscribed to by the StreakSystemReactive contract which emits a callback event picked up by the MintNFTCallback contract on the destination chain which then mints the NFT. Separating the streak system from the minting in this way means that NFTs can be minted on any chain supported by Reactive and even on multiple chains if needed. This makes then streak system very modular and flexible.

### Streak System Reactive
Subscribes to the EarnedNFT event and emits a callback event that includes the user address and tokenId to mint.

### MintNFTCallback
Handles the callback event and mints the NFT. Is linked to an NFT contract, in this case an ERC1155 contract.

### Rogues Items
The ERC1155 contract. Implements all the on-chain game items in World of Rogues.

## Testnet Deployment
```
4 Contracts need to be deployed: (replace below addresses with your own as you deploy)
StreakSystem - Reactive - 0xb1E0Cfc0D39112DC4765097a98F74A525bC6a0B4
StreakSystemReactive - Reactive - 0x08E88D7Dc8bb2cA8b1F6daAC86063E8036A49Eb2
MintNFTCallback - Ethereum - 0xac2BA078DdadF1a0fA1208ecAf21ac18ba18F6E7
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
ORIGIN_ADDR=0xb1E0Cfc0D39112DC4765097a98F74A525bC6a0B4
# The deployed address of the MintNFTCallback contract
CALLBACK_ADDR=0xac2BA078DdadF1a0fA1208ecAf21ac18ba18F6E7

forge create --legacy --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/StreakSystemReactive.sol:StreakSystemReactive --value 0.01ether --constructor-args $SYSTEM_CONTRACT_ADDR $REACTIVE_CHAIN_ID $DESTINATION_CHAIN_ID $ORIGIN_ADDR $CALLBACK_ADDR

forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID $ORIGIN_ADDR StreakSystem

forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID 0x08E88D7Dc8bb2cA8b1F6daAC86063E8036A49Eb2 StreakSystemReactive

forge verify-contract --chain-id $DESTINATION_CHAIN_ID $CALLBACK_ADDR --etherscan-api-key $ETHERSCAN_API_KEY MintNFTCallback

forge verify-contract --chain-id $DESTINATION_CHAIN_ID $ERC1155_ADDR --etherscan-api-key $ETHERSCAN_API_KEY RoguesItems

```
## Testnet deployment
Streak System deployment on Kopli:

https://kopli.reactscan.net/tx/0xfd73f99cf2d3814de42d9b0a4c310da3d3233541456f931159c6a1188ea444d8

## Interacting

```bash
cast call $ORIGIN_ADDR "streakIncrementTime()(uint256)" --rpc-url $REACTIVE_RPC

cast call $ORIGIN_ADDR "streak(address)(uint256)" 0x7990ec7597e6215958c9bbef7d555f7b72f6b8de --rpc-url $REACTIVE_RPC

#Grant the minter role to the MintNFTCallback contract
cast send --legacy $ERC1155_ADDR "grantMinterRole(address)" $CALLBACK_ADDR --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY

cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 1 13 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

cast send --legacy $ORIGIN_ADDR "setStreakResetTime(uint256)" 1 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

cast send --legacy $ORIGIN_ADDR "claim()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

```

## Mainnet deploymet

```bash
4 Contracts need to be deployed: (replace below addresses with your own as you deploy)
StreakSystem - Reactive - 0x2eB75a1429F6fE2d60F783c73d656D977AbdfCf9
StreakSystemReactive - Reactive - 0xC5Bd3532198e2D561f817c22524D1F6f10415bc2
MintNFTCallback - Reactive - 0x9e3cfE53149adBa88433cB74BE5c1c6aC6A4C097
RoguesItems - Reactive - 0x8897167068573d6228Ee8eC62E9DCCEeD193f89F



SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000fffFfF
REACTIVE_RPC=https://mainnet-rpc.rnk.dev

forge create --legacy --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/StreakSystem.sol:StreakSystem
REACTIVE_CHAIN_ID=1597
ORIGIN_ADDR=0x2eB75a1429F6fE2d60F783c73d656D977AbdfCf9
forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID $ORIGIN_ADDR StreakSystem
DESTINATION_RPC=https://mainnet-rpc.rnk.dev
forge create --legacy --broadcast --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/RoguesItems.sol:RoguesItems
ERC1155_ADDR=0x8897167068573d6228Ee8eC62E9DCCEeD193f89F
forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID $ERC1155_ADDR RoguesItems
DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000fffFfF
forge create --legacy --broadcast --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/MintNFTCallback.sol:MintNFTCallback --value 0.05ether --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR $ERC1155_ADDR
CALLBACK_ADDR=0x9e3cfE53149adBa88433cB74BE5c1c6aC6A4C097
forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID $CALLBACK_ADDR MintNFTCallback
DESTINATION_CHAIN_ID=1597
forge create --legacy --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/StreakSystemReactive.sol:StreakSystemReactive --value 0.01ether --constructor-args $SYSTEM_CONTRACT_ADDR $REACTIVE_CHAIN_ID $DESTINATION_CHAIN_ID $ORIGIN_ADDR $CALLBACK_ADDR
forge verify-contract --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --chain-id $REACTIVE_CHAIN_ID 0xC5Bd3532198e2D561f817c22524D1F6f10415bc2 StreakSystemReactive
cast send --legacy $ERC1155_ADDR "grantMinterRole(address)" $CALLBACK_ADDR --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY

cast send --legacy $ERC1155_ADDR "setURI(string)" "ipfs://QmbtJEzuMC5LjdBp4xhUFrubBGTx3uzHeSdzKvjWjeaNpm/" --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY

cast call $ERC1155_ADDR "uri(uint256)(string)" 1 --rpc-url $REACTIVE_RPC
#Set up rewards
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 1 1 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 5 2 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 10 3 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 15 4 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 20 5 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 25 6 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 30 7 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 35 8 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 40 9 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
cast send --legacy $ORIGIN_ADDR "setTokenMilestone(uint256,uint256)" 50 10 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY

#

cast send --legacy $ORIGIN_ADDR "claimFor(address)" 0xcE6fF2Ad12F4A27d490FEd5A42b0fDDEf164D6F5 --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY
cast call $ORIGIN_ADDR "streak(address)(uint256)" 0x7990ec7597e6215958c9bbef7d555f7b72f6b8de --rpc-url $REACTIVE_RPC


cast call $ERC1155_ADDR "balanceOf(address,uint256)(uint256)" 0x7990ec7597e6215958c9bbef7d555f7b72f6b8de 1 --rpc-url $REACTIVE_RPC

cast call $ERC1155_ADDR "balanceOfBatchOneAddr(address,uint256[])(uint256[])" 0xcE6fF2Ad12F4A27d490FEd5A42b0fDDEf164D6F5 "[1,2,3,4,5,6,7,8,9,10]" --rpc-url $REACTIVE_RPC

cast send --legacy $ORIGIN_ADDR "setStreakIncrementTime(uint256)" 1 --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY


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

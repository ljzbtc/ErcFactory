### Contract Address

- UUPSFactory Proxy deployed at: 0x6E04D09003426B45972B0DDE346A292cD1E26Bc4
- ImplementationV1 deployed at: 0xc9F44C325D125cE101D35dE5eBad68d3BF4F0D3E
- ImplementationV2 0xb11D598F37D34699644b73e3De472f51253dc58e
  - ERC20Implementation 0x248B9478465e8b8aF368eAEAB06021F6eB0EBf69Proxy






## deploy and verifyContract

source .env

forge script --account dev --chain sepolia script/deployer.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv --sender 0x2cf56496f155914d84e6eda6e2c0076aeae5b0f0

## verify-contract

forge verify-contract 0x50c56eb8e5c30992cba712246b72b94968263bb9 TradeDevil --chain sepolia

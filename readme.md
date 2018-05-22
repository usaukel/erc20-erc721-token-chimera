# Token Chimera
## A combination of ERC-20 and ERC-721

### Intro
This repo contains a smart contracts experiment to demonstrate how the characteristics of erc20 and erc721 could be combined for a token that is backed by physical assets.

![A schematic layout of the contract](https://github.com/BlockChainCompany/erc20-erc721-token-chimera/blob/master/images/smart_contract.png)

### Getting started
- Run `npm install` to install all depencies
- Run `npm run test` for the example truffle test

### Properties of the contract

*owner*
The owner of the contract

*minter*
The minter of physical assets

*name*
The title of the asset

*description*
A description of the asset

### Asset properties
The contract maintains a list of assets that back the value of the balances.

*assetId*
The unique id of the asset.

*mediaUri*
The uri that holds the metadata of the asset.

### Methods
*addAsset*
Add an asset to the contract. Can only be called by the owner of the contract.

*removeAsset*
Removes an asset from the contract. Can only be called by the owner of the contract.

*addMediaUri*
Add a new mediaUri to an asset.

*transfer* & *tranferFrom*
Allows a person to transfer a (piece) of an asset if he is the owner or is allowed to by the owner of the asset.

*balanceOf*
Get the balance of an address.

### Events
The basket smart contains the following four events:
- AddAsset
- RemoveAsset
- AddMediaUri
- Transfer
- Approve
- Mint

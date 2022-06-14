# NFTS FULL REPO 🌃🌟

This is a repo about NFTs. This repo is similar to the [NFT-dynamic-fully-on-chain](https://github.com/JMariadlcs/NFT-dynamic-fully-on-chain) and [NFT-IPFS-VRF](https://github.com/JMariadlcs/NFT-IPFS-VRF) repos but all together and much complete. Testing is done in this repo.

Altough this repo is a similar implementation of the other 2 mentioned repos, this one is more structurated, is constructed in such a way that can be deployed on different chains automatically and testing is done and [pinata](https://www.pinata.cloud/) is used to host NFT Uris.

This is a workshop from Patrick Alpha's FFC couse.

The workshop followed to complete this repo is [this one](https://github.com/PatrickAlphaC/hardhat-nft-fcc).

The repo that we are going to implement is like [this one](https://www.youtube.com/watch?v=gyMwXuJrbJQ&t=15996s).

<br/>
<p align="center">
<img src="./images/randomNft/pug.png" width="225" alt="NFT Pug">
<img src="./images/randomNft/shiba-inu.png" width="225" alt="NFT Shiba">
<img src="./images/randomNft/st-bernard.png" width="225" alt="NFT St.Bernard">
</p>
<br/>
<br/>
<p align="center">
<img src="./images/dynamicNft/happy.svg" width="225" alt="NFT Happy">
<img src="./images/dynamicNft/frown.svg" width="225" alt="NFT Frown">
</p>
<br/>

## PROJECT

We are creating 3 contracts for different NFT implementations:

1. Basic NFT ✅.
2. Random IPFS NFT ✅.
    - Pros: Cheap.
    - Cons: Someone needs to pin our data.
3. Dynamic SVG NFT ✅.
    - Pros: Data is on-chain.
    - Cons: Much more expensive.
    - Objetives: Mint an NFT based on the price of ETH
        - If ETHprice > someNumer: NFT1
        - if ETHprice < someNumber: NFT2

## CREATE SIMILAR PROJECT FROM SCRATCH

-   Install yarn and start hardhat project:

```bash
yarn
yarn add --dev hardhat
yarn hardhat
```

-   Install ALL the dependencies:

```bash
yarn add --dev @nomiclabs/hardhat-waffle@^2.0.0 ethereum-waffle@^3.0.0 chai@^4.2.0 @nomiclabs/hardhat-ethers@^2.0.0 ethers@^5.0.0 @nomiclabs/hardhat-etherscan@^3.0.0 dotenv@^16.0.0 eslint@^7.29.0 eslint-config-prettier@^8.3.0 eslint-config-standard@^16.0.3 eslint-plugin-import@^2.23.4 eslint-plugin-node@^11.1.0 eslint-plugin-prettier@^3.4.0 eslint-plugin-promise@^5.1.0 hardhat-gas-reporter@^1.0.4 prettier@^2.3.2 prettier-plugin-solidity@^1.0.0-beta.13 solhint@^3.3.6 solidity-coverage@^0.7.16 @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @chainlink/contracts hardhat-deploy hardhat-shorthand @aave/protocol-v2
```

-   Install OpenZeppelin dependencies (contracts):

```bash
yarn add --dev @openzeppelin/contracts
```

-   Install Base64 dependencies (to encode SVGs):

```bash
yarn add --dev base64-sol
```

## UPLOAD FILES TO PINATA

-   Use [pinata](https://www.pinata.cloud/):

```bash
yarn add --dev @pinata/sdk
yarn add --dev path
```

-   Create [uploadToPinata](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/utils/uploadToPinata.js) folder and execute:

```bash
yarn hardhat deploy --tags randomipfs
```

## HOW TO COMPILE

```bash
yarn hardhat compile
```

or

```bash
npx hardhat compile
```

## HOW TOT DEPLOY

If you want to use [Hardhat shorthand](https://hardhat.org/guides/shorthand):

```bash
yarn global add hardhat-shorthand
```

-   Deploy to local network (Harhat by default):

```bash
hh compile
hh deploy
```

-   Deploy to a TESTNET (Rinkeby):
    You can not deploy all scripts at the same time because you can deploy [mint.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/deploy/04-mint.js) script without firtly add randomNFT to ConsumerBase.

To deploy every script expect [mint.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/deploy/04-mint.js):

```bash
yarn hardhat deploy --network rinkeby --tags main
```

## HOW TO TEST

Two types of tests are created for this project:

1. "Unit tests" inside [unit](https://github.com/JMariadlcs/nfts-fullrepo/tree/main/test/unit): used to test functions separately

To execute tests **unit tests** (on development chain):

```bash
yarn hardhat test
```

and to see test coverage:

```bash
yarn hardhat coverage
```

## REMINDERS

**NOTICE**: most of the below mentioned dependencies are already installed, just check it and include the corresponding `requires` inside [hardhat.config.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/hardhat.config.js).

-   If you want to execute solhint to search for potential Solidity errors
    Execute:

```bash
yarn solhint contracts/*.sol
```

-   If you want to use a text formarter:
    Check [.prettierrc](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/.prettierrc) and [.prettierignore](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/.prettierignore).

-   To automatically verify our contract on etherscan:

```bash
yarn add --dev @nomiclabs/hardhat-etherscan
```

Then, include inside [hardhat.config.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/hardhat.config.js):

```bash
require("@nomiclabs/hardhat-etherscan");
```

Add `ETHERSCAN_API_KEY` inside `.env` file.

-   Use Hardhat Gas Reporter:

```bash
yarn add --dev hardhat-gas-reporter
```

Then, include inside [hardhat.config.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/hardhat.config.js):

```bash
require("hardhat-gas-reporter");
```

-   Use Solidity Coverage:

```bash
yarn add --dev solidity-coverage
```

Then, include inside [hardhat.config.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/hardhat.config.js):

```bash
require("solidity-coverage");
```

In order to execute it:

```bash
yarn hardhat coverage
```

-   Use Hardhat Waffle:

```bash
yarn add @nomiclabs/hardhat-waffle
```

Then, include inside [hardhat.config.js](https://github.com/JMariadlcs/nfts-fullrepo/blob/main/hardhat.config.js):

```bash
require("@nomiclabs/hardhat-waffle");
```

## RESOURCES

1. BASIC NFT:

-   [Openzeppelin github](https://github.com/OpenZeppelin/openzeppelin-contracts)
-   [Openzeppelin ERC721](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721)
-   [Openzeppelin ERC721 Smart Contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)

2. RANDOM NFT:

-   [hardhat-nft-fcc](https://github.com/PatrickAlphaC/hardhat-nft-fcc): Patrick's repo for NFTs
-   [hardhat-starter-kit](https://github.com/smartcontractkit/hardhat-starter-kit)
-   [OpenZeppeling github](https://github.com/OpenZeppelin/openzeppelin-contracts): OpenZeppeling github
-   [Chainlink VRF](https://docs.chain.link/docs/get-a-random-number/): NECESARY for getting an actually random number
-   [Chainlink VRF contract addresses](https://docs.chain.link/docs/vrf-contracts/): Smart Contract addresses for Chainlink VRF (VRFCoordinator and Key Hash)
-   [Chainlink VRF subscription](https://vrf.chain.link): Needed to create subscriptionId for using Chainlink VRF - Create subscription - add funds - get 'ID' - add deployed Smart Contract address as consumer
-   [pinata](https://www.pinata.cloud/)

3. DYNAMIC SVG NFT:

-   [hardhat-nft-fcc](https://github.com/PatrickAlphaC/hardhat-nft-fcc): Patrick's repo for NFTs.
-   [hardhat-starter-kit](https://github.com/smartcontractkit/hardhat-starter-kit)
-   [OpenZeppeling github](https://github.com/OpenZeppelin/openzeppelin-contracts): OpenZeppeling github.
-   [ERC721 JSON example](https://data:application/json;base64eyJuYW1lIjoiQ2hhaW5saW5rIEZlZWRzIE5GVCIsICJkZXNjcmlwdGlvbiI6IkFuIE5GVCB0aGF0IGNoYW5nZXMgYmFzZWQgb24gdGhlIENoYWlubGluayBGZWVkIiwgImF0dHJpYnV0ZXMiOiIiLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIyWlhKemFXOXVQU2N4TGpFbklHbGtQU2RNWVhsbGNsOHhKeUI0Yld4dWN6MG5hSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY25JSGh0Ykc1ek9uaHNhVzVyUFNkb2RIUndPaTh2ZDNkM0xuY3pMbTl5Wnk4eE9UazVMM2hzYVc1ckp5QjRQU2N3Y0hnbklIazlKekJ3ZUNjZ2QybGtkR2c5SnpJMk1IQjRKeUJvWldsbmFIUTlKekkwTkhCNEp5QjJhV1YzUW05NFBTY3dJREFnTWpZd0lESTBOQ2NnWlc1aFlteGxMV0poWTJ0bmNtOTFibVE5SjI1bGR5QXdJREFnTWpZd0lESTB%20OQ2NnZUcxc09uTndZV05sUFNkd2NtVnpaWEoyWlNjK1BIQmhkR2dnWkQwblRUSTFPQ3d4TVRoMk9UWmpNQ3d4TkM0ek16TXRNVE11TmpZM0xESTRMVEk0TERJNGFDMDROR010TVRjdU5ETTVMREF0TXpFdU5UY3hMVEl1TVRVeUxUUTRMVGhqTFRVdU1EY3pMVEV1T0RBMkxUSXdMVGd0TWpBdE9GWXhNVFJzTmpZdU1ETTJMVGMzTGpVMk4wd3hOVEFzTW1neE1tTXhNeTR5T1RRc01Dd3lNaTQyTlRjc01UQXVOakEzTERJeUxqWTFOeXd5TXk0NU1ESjJOeTQwTnpkak1Dd3hOeTR3TmpVdE1TNHdNamdzTXpRdU1URTFMVE11TURjNExEVXh): remove 'https://'
-   [SVG documentation](https://www.w3schools.com/graphics/svg_intro.asp): SVG documentation and examples.
-   [SVG real time encoding](https://www.w3schools.com/graphics/tryit.asp?filename=trysvg_myfirst): encode SVG and see result in real time.
-   [Base64.sol SmartContract](https://github.com/Brechtpd/base64/blob/main/base64.sol): used to base64 encode SVGs
-   [Chainlink Data Feeds](https://docs.chain.link/docs/get-the-latest-price/): Chainlink Data Feeds documentation for getting ETH price.
-   [Ethereum Price Data Feed](https://docs.chain.link/docs/ethereum-addresses/): Needed when deploy

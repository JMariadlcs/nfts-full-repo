/**  Script used to execute unit testing -> ONLY ON DEVELOPMENT CHAINS
 *    To execute all the test: yarn hardhat test
 *    To execute a single test (eg.1st test): yarn hardhat test --grep ""
 *    To see coverage: yarn hardhat coverage
 */


 const { network, deployments, ethers, getNamedAccounts } = require("hardhat")
 const { assert, expect } = require("chai")
 const { developmentChains, networkConfig } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name) ? describe.skip : // case WE ARE in a development chain -> deploy Mocks
    describe("BasicNFT Unit Tests", function () {
        let basicNft, deployer

        beforeEach(async () => {
            accounts = await ethers.getSigners()
            deployer = accounts[0]
            await deployments.fixture(["mocks", "basicnft"])
            basicNft = await ethers.getContract("BasicNft")
        })

        it("Allows users to mint one NFT, and updates correctly", async function () {
            const txResponse = await basicNft.mintNft()
            await txResponse.wait(1)
            const tokenURI = await basicNft.tokenURI(0)
            const tokenCounter = await basicNft.getTokenCounter()

            assert.equal(tokenCounter.toString(), "1")
            assert.equal(tokenURI, await basicNft.TOKEN_URI())
        })
    })
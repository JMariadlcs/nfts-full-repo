/* This Script is used to deploy BasicNFT.sol contract:
    - LOCALLY:
        Deploy all scripts: 'yarn hardhat deploy'
        Deploy ONLY this script: 'yarn hardhat deploy --tags basicnft'
    - TESTNET
        Deploy all scripts: 'yarn hardhat deploy --network rinkeby'
        Deploy ONLY this script: 'yarn hardhat deploy --tags basicnft --network rinkeby'
*/

const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    log("----------------------------------------------------")
    args = []
    const basicNft = await deploy("BasicNft", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(basicNft.address, args)
    }
}

module.exports.tags = ["all", "basicnft", "main"]
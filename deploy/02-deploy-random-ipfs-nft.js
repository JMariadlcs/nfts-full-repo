const { network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { storeImages } = require("../utils/uploadToPinata")
const { verify } = require("../utils/verify")
const fs = require("fs")

const imagesLocation = "./images/randomNft"
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let tokenUris

    if (process.env.UPLOAD_TO_PINATA == "true") {
        tokenUris = await handleTokenUris()
    }

    let vrfCoordinatorV2Address, subscriptionId

    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const transactionResponse = await vrfCoordinatorV2Mock.createSubscription() // create VRF SubscriptionId
        const transactionReceipt = await transactionResponse.wait(1) // inside `transactionReceipt`is the SubscriptionId
        subscriptionId = transactionReceipt.events[0].args.subId

    } else { // not localnetwork -> pick from networkConfig
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"]
        subscriptionId = networkConfig[chainId]["subscriptionId"]
    }

    log("----------------------------------------------------")
    
    await storeImages(imagesLocation)
    //const args = [vrfCoordinatorV2Address, subscriptionId, networkConfig[chainId]["gasLane"], networkConfig[chainId]["callbackGasLimit"], /*tokenUris */, networkConfig[chainId]["mintFee"]]
    /*
    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(dynamicSvgNft.address, arguments)
    }*/
}

async function handleTokenUris() {
    tokenUris = []

    // 1. store Image in IPFS

    // 2. store Metadata in IPFS
    return tokenUris;
}

module.exports.tags = ["all", "randomipfs", "main"]
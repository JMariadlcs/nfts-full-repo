// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 
import "base64-sol/base64.sol";

/**
* @dev
* 1. Mint an NFT based on the price of ETH
* - If ETHprice  > someNumer: NFT1
* - if ETHprice < someNumber: NFT2
*/
contract DynamicSvgNft is ERC721 {

    /// @notice // Chainlink price feed variables
    AggregatorV3Interface internal immutable i_priceFeed; 

    /// @notice Nft Variables
    uint256 private s_tokenCounter; // NFTid
    string private s_lowImageURI; // frown image
    string private s_highImageURI; // high image
    string private constant base64EncodedSvgPrefix = "data:image/svg+xml;base64,"; // used to genera SVG onchain
    int256 public immutable i_threshold; // threshold to decide which image to pick
   

    constructor(address priceFeedAddress, string memory lowSvg, string memory highSvg, int256 threshold) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        s_lowImageURI = svgToImageURI(lowSvg);
        s_highImageURI = svgToImageURI(highSvg); 
        i_priceFeed = AggregatorV3Interface(priceFeedAddress); // get price feed Smart Contract (Interface(Address) == Contract)
        i_threshold = threshold;
    }

    // FUNCIONS RELATED TO NFT

    /**
    * @notice convert svg to base64 encoded
    * @dev
    * - Encode svg image and join to the base64EncodedSvgPrefix 
    * - Return generated string
    */
    function svgToImageURI(string memory svg) public pure returns(string memory) { 
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
    }

    /**
    * @notice function to mint NFT
    * @dev
    * - Mint NFT using OpenZeppeling function
    * - Update s_tokenCounter
    */
    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter +1; 
    }

    /// @notice function to return first part of URI
    function _baseURI() internal pure override returns(string memory) {
        return "data:application/json;base64,";
    }

    /**
    * @notice Function to generate tokenURI onChain
    * @dev
    * If its 'override' because openzeppeling ERC721.sol already has tokenURI function and we
    * are overriding our own function (create a different one)
    * 'virtual override': would mean that the function is overridable
    * - Encode JSON with Base64.sol
    * - 'pure' function because does not read neither write any state from the blockchain
    */
    function tokenURI(uint256 /*tokenId*/) public view override returns(string memory) {

        // part used to select image depeding on ETH price
        (, int256 price, ,,) = i_priceFeed.latestRoundData(); // see Chainlink Data Feed documentation
        string memory imageUri = s_lowImageURI; // set image to low image
        if(price > i_threshold) { // if price is high set it to high image
            imageUri = s_highImageURI;
        }

        bytes memory metaDataTemplate = (
            abi.encodePacked('{"name":"Dyamic NFT", "description":"An NFT that changes based on the Chainlink Feed", "attributes":[{"trait_type": "coolness", "value": 100}], "image":"',
            imageUri,
            '"}'
            ));
            
        bytes memory metaDataTemplateInBytes = bytes(metaDataTemplate); // nedeed to use Base64.sol encode() function
        string memory encodedMetada = Base64.encode(metaDataTemplateInBytes);
        
        return (string(abi.encodePacked(_baseURI(), encodedMetada))); // return both strings concatenated (baseURI + encodedMEtada) = fullJSON encoded except image 
    }

    // GETTERS FUNCTIONS
    function getLowSVG() public view returns (string memory) {
        return s_lowImageURI;
    }

    function getHighSVG() public view returns (string memory) {
        return s_highImageURI;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
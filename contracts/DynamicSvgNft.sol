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

    /// @notice Chainlink price feed variables
    AggregatorV3Interface internal immutable i_priceFeed; 

    /// @notice Nft Variables
    uint256 private s_tokenCounter; // NFTid
    string private s_lowImageURI; // frown image
    string private s_highImageURI; // high image
    string private constant base64EncodedSvgPrefix = "data:image/svg+xml;base64,"; // used to genera SVG onchain
    mapping(uint256 => int256) public s_tokenIdToHighValue;

    /// @notice Events
   event CreatedNFT(uint256 indexed tokenId, int256 highValue);

    constructor(address priceFeedAddress, string memory lowSvg, string memory highSvg) ERC721("Dynamic SVG NFT", "DSN") {
        i_priceFeed = AggregatorV3Interface(priceFeedAddress); // get price feed Smart Contract (Interface(Address) == Contract)

        s_lowImageURI = svgToImageURI(lowSvg);
        s_highImageURI = svgToImageURI(highSvg); 
        s_tokenCounter = 0;
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
    * - Users can select threshold of deciding NFT (highValue)
    * - Mint NFT using OpenZeppeling function
    * - Update s_tokenCounter
    * - Emit event
    */
    function mintNft(int256 highValue) public {
        s_tokenIdToHighValue[s_tokenCounter] = highValue;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter +1; 
        emit CreatedNFT(s_tokenCounter, highValue);
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
    * - Should check that tokenId exists, if not -> revert
    * - Should encode base64 to bytes metadata
    * - Should join baseURI and metadata
    */
    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // Part used to select image depeding on ETH price using Chainlink PriceFeed
        (, int256 price, ,,) = i_priceFeed.latestRoundData(); 
        string memory imageUri = s_lowImageURI; 
        if(price > s_tokenIdToHighValue[tokenId]) { 
            imageUri = s_highImageURI;
        }

        // set NFT metadata JSON
        bytes memory metaDataTemplate = (
            abi.encodePacked('{"name":"',name(),'", "description":"An NFT that changes based on the Chainlink Feed", "attributes":[{"trait_type": "coolness", "value": 100}], "image":"',
            imageUri,
            '"}'
            ));
            
        bytes memory metaDataTemplateInBytes = bytes(metaDataTemplate); // nedeed to use Base64.sol encode() function
        string memory encodedMetada = Base64.encode(metaDataTemplateInBytes);
        
        return (string(abi.encodePacked(_baseURI(), encodedMetada))); // return both strings concatenated (baseURI + encodedMEtada) = fullJSON encoded 
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
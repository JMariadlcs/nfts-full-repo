// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // to use _setTokenUri function
import "@openzeppelin/contracts/access/Ownable.sol"; // to use onlyOwner modifier
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol"; // to work with COORDINATOR and VRF
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol"; // to use functionalities for Chainlink VRF

error RandomIpfsNfts__RangeOutOfBounds();
error RandomIpfsNfts__NeedMoreETHSent();
error RandomIpfsNfts__TransferFailed();

contract RandomIpfsNft is ERC721URIStorage, VRFConsumerBaseV2, Ownable {

    /// @notice Types
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    /// @notice Chainlink VRF Variables
    VRFCoordinatorV2Interface immutable i_vrfCoordinator; 
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3; 
    uint32 private constant NUM_WORDS = 1; 

    /// @notice VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;
    
    /// @notice NFTS variables
    uint256 private constant MAX_CHANCE_VALUE = 100;
    uint256 public s_tokenCounter;
    string[3] internal s_dogTokenUris;
    uint256 internal immutable i_mintFee;

    /// @notice Events
    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(Breed dogBreed, address minter);
   
    /**
    * @dev 
    * - We are going to use VRFrequestRandomWords() function from Chainlink VRF
    * so we need to define each parameter that function uses in our contract constructor
    */
    constructor(address vrfCoordinatorV2, uint64 subscriptionId, bytes32 gasLane, uint32 callbackGasLimit, string[3] memory dogTokenUris, uint256 mintFee) ERC721("Random IPFS NFT", "RIN") VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2); 
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane; 
        i_callbackGasLimit = callbackGasLimit;

        s_tokenCounter = 0;
        s_dogTokenUris = dogTokenUris;
        i_mintFee = mintFee;
    }

    // FUNCTIONS RELATED TO NFT 

    /**
    * @notice Mint a random puppy (get random number) -> use Chainlink VRF -> call requestRandomWords() function
    * @dev 
    * - Should be payable
    * - Should check that msg.value => mintFee
    * - Emit event
    */
    function requestNFT() public payable returns (uint256 requestId){
        if (msg.value < i_mintFee) {
            revert RandomIpfsNfts__NeedMoreETHSent();
        }

        requestId = i_vrfCoordinator.requestRandomWords(i_gasLane, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS);
        s_requestIdToSender[requestId] = msg.sender; 
        emit NftRequested(requestId, msg.sender);
    }

    /**
    * @notice Function that Chainlink Node uses to get Random Number
    * @dev 
    * - Assign this NFT a tokenId || update NFT id
    * - Compute MOD of gotten random number -> to avoid having numbers like: 4869259398298299
    * - Get Dog Breed
    * - Use _safeMint() function from OpenZeppelin
    * - Set tokenURI | params -> tokenId, tokenURI
    * - Emit event
    */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1; 

        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE; 
        Breed dogBreed = getBreedFromModdedRng(moddedRng); 

        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);
        emit NftMinted(dogBreed, dogOwner);
    }

    /**
    * @notice Function that assing the chances of each NFT
    * @dev Pure because only read state variables
    */
    function getChanceArray() public pure returns(uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    /**
    * @notice Function to decide puppy breed randomly
    * @dev 
    * - 0-10: st.bernard
    * - 11-30: pug
    * - 12 - 100: shiba 
    * - Returns Breed
    * - Revert if range is out of bounds
    */
    function getBreedFromModdedRng(uint256 moddedRng) public pure returns (Breed) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        
        for (uint256 i=0; i < chanceArray.length; i++){
            if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]){
                return Breed(i);
            }
            cumulativeSum += chanceArray[i];
        }
        revert RandomIpfsNfts__RangeOutOfBounds();
    }

    // FUNCTIONS REALTED TO CONTRACT MANAGEMENT

    /**
    * @notice Function to withdraw funds
    * @dev 
    * - Only owner can withdraw funds
    * - Check that transaction has succeffully completed
    * - Revert if transaction failed
    */
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if(!success) { 
            revert RandomIpfsNfts__TransferFailed();
        }
    }

    // GETTERS FUNCTION 

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUris(uint256 index) public view returns (string memory) {
        return s_dogTokenUris[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
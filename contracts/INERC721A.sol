// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

//import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "erc721a/contracts/ERC721A.sol";

contract INERC721A is ERC721A, Ownable {
    using Strings for uint256;
    
    string public baseURI;
    string public baseExtension = ".json";
    bool paused = false;
    bool valid = true;
    address adressMarketPlace;
    uint256 countToken;
    uint256 baseCollectionPrice;
    string _contractURI;

    event Mints(uint256 indexed id, address minter);

    constructor(string memory name, string memory symbol, string memory _initBaseURI) ERC721A(name, symbol){
        setBaseURI(_initBaseURI);
        valid = true;
        //multipleMint(mintNumber);
    }

    ///@dev for Opensea metadata
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    ///@dev set metadata opensea
    function setContractURI(string memory _URI) external {
        _contractURI = _URI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
    All functions using this modifier can only be called by the delegation contract
     */
    modifier byDelegate() {
        require((msg.sender == adressMarketPlace || adressMarketPlace == address(0))&& !paused,"Not good address delegate contract");
        _;
    }

    ///@dev Temporarily lock the contract
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    ///@dev Mint a token with parameter send in function argument 
    function mint(address sender) external onlyOwner {
        _safeMint(sender, 1);
        countToken++;
    }

    function multipleMint(uint256 quantity) external onlyOwner {
        _safeMint(msg.sender, quantity);
        countToken+=quantity;
    }

    /**
    Safe transfer one token to another address
     */
    function transfer(address from, address to ,uint256 tokenId) external byDelegate {
        safeTransferFrom(from, to, tokenId);
    }

    /**
    Update the only address that will be able to call on the token contract 
    */
    function setAdressMarketPlace(address _adress) external onlyOwner {
        adressMarketPlace = _adress;
    }

    function getAdressMarketPlace() external view returns (address){
        return adressMarketPlace;
    }

    /*function getTokenDetails(uint256 tokenId) external view returns (Token memory){
        return _tokenDetails[tokenId];
    }

    function getAllToken() external view returns (Token[] memory){
        Token[] memory result = new Token[](countToken);
        for(uint256 i = 0; i < countToken; i++){
            Token storage _token = _tokenDetails[i];
            result[i] = _token;
        }
        return result;
    }*/

    function getOwnerOf(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }
    
    /**
    Burn a token (Useless for this project, but it's always good to have one)
     */
    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function getValid() external view returns (bool) {
        return valid;
    }

}

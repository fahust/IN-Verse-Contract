// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "erc721a/contracts/ERC721A.sol";

contract TokenContract is ERC721A, Ownable {
    using Strings for uint256;
    
    /*
    Object of Token
     */
    struct Token {
        address addrOwner;
        string uri;
        string url;
        uint256 price;
    }

    mapping( string => uint ) paramsContract;
    mapping( uint256 => Token ) private _tokenDetails;
    string public baseURI;
    string public baseExtension = ".json";
    bool paused = false;
    bool valid = true;
    address adressDelegateContract;
    uint256 countToken;
    uint256 baseCollectionPrice;
    uint256[] tokenLocked;
    uint256[] tokenSelled;
    string contractURI;

    event Mints(uint256 indexed id, address minter);

    constructor(string memory name, string memory symbol, string memory _initBaseURI,uint256 mintNumber) ERC721A(name, symbol){
        setBaseURI(_initBaseURI);
        valid = true;
        //multipleMint(mintNumber);
    }

    ///@dev for Opensea metadata
    function contractURI() public view returns (string memory) {
        return contractURI;
    }

    ///@dev set metadata opensea
    function setContractURI(string memory _contractURI) external {
        contractURI = _contractURI;
    }

    function purchase(uint256 idToken) external payable {
        uint256 currentPrice = _tokenDetails[idToken].price==0?baseCollectionPrice:_tokenDetails[idToken].price;
        require(currentPrice!=0,"Price is not setted");
        require(msg.value>=currentPrice,"Not enought value sended");

    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /*function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require( _exists(tokenId), "ERC721Metadata: URI query for nonexistent token" );
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }*/

    /**
    All functions using this modifier can only be called by the delegation contract
     */
    modifier byDelegate() {
        require((msg.sender == adressDelegateContract || adressDelegateContract == address(0))&& !paused,"Not good address delegate contract");
        _;
    }

    ///@dev Temporarily lock the contract
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    ///@dev Mint a token with parameter send in function argument 
    function mint(address sender, string memory uri, string memory url) external byDelegate {
        _tokenDetails[countToken] = Token(sender,uri,url);
        _safeMint(sender, 1);
        //_setTokenURI(countToken,uri);
        countToken++;
    }

    /*function lazyMint(address sender){
        require(sender == owner(),"tu n'es pas le créateur");
        require(msg.sender == auctionContract);
    }*/

    function multipleMint(uint256 quantity) external onlyOwner {
        _safeMint(msg.sender, quantity);
        countToken+=quantity;
        /*for (uint256 index = 0; index < number; index++) {
            _safeMint(msg.sender, _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }*/
    }

    /**
    Safe transfer one token to another address
     */
    function transfer(address from, address to ,uint256 tokenId) external byDelegate {
        safeTransferFrom(from, to, tokenId);
    }

    /**
    Set array of contract's parameter dynamicaly, possibility of add an infinite of parameters
     */
    function setParamsContract(string memory keyParams, uint valueParams) external onlyOwner {
        paramsContract[keyParams] = valueParams;
    }

    /**
    Get value of one element of array parameter of contract
     */
    function getParamsContract(string memory keyParams) external view returns (uint){
        return paramsContract[keyParams];
    }

    /**
    Update the only address that will be able to call on the token contract 
    */
    function setAdressDelegateContract(address _adress) external onlyOwner {
        adressDelegateContract = _adress;
    }

    function getAdressDelegateContract() external view returns (address){
        return adressDelegateContract;
    }

    function getTokenDetails(uint256 tokenId) external view returns (Token memory){
        return _tokenDetails[tokenId];
    }

    function getAllToken() external view returns (Token[] memory){
        Token[] memory result = new Token[](countToken);
        for(uint256 i = 0; i < countToken; i++){
            Token storage _token = _tokenDetails[i];
            result[i] = _token;
        }
        return result;
    }

    function getOwnerOf(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }

    /**
    update the values of the token structure dynamicaly
    */
    function updateToken(Token memory _token,uint256 tokenId,address owner) external byDelegate {
        require(ownerOf(tokenId) == owner,"Not Your token");
        _tokenDetails[tokenId] = _token;
    }
    
    /**
    Burn a token (Useless for this project, but it's always good to have one)
     */
    function burn(uint256 tokenId) external byDelegate {
        _burn(tokenId);
    }

    function getValid() external view returns (bool) {
        return valid;
    }

}

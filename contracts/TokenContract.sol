// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import './AuctionContract.sol';

contract TokenContract is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    
    /*
    Object of Token
     */
    struct Token {
        address addrOwner;
        string uri;
        uint8[] params8;
        uint256[] params256;
    }

    mapping( string => uint ) paramsContract;
    mapping( uint256 => Token ) private _tokenDetails;
    string public baseURI;
    string public baseExtension = ".json";
    bool paused = false;
    address adressDelegateContract;

    constructor(string memory name, string memory symbol, string memory _initBaseURI,uint256 mintNumber) ERC721(name, symbol){
        setBaseURI(_initBaseURI);
        paramsContract["params8Count"] = 5;
        paramsContract["params256Count"] = 5;
        multipleMint(mintNumber,_initBaseURI);
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

    /**
    Temporarily lock the contract
     */
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    /**
    Mint a token with parameter send in function argument 
     */
    function mint(address sender, string memory uri, uint8[] memory params8, uint256[] memory params256) external byDelegate {
        _tokenDetails[_tokenIdTracker.current()] = Token(sender,uri,params8,params256);
        _safeMint(sender, _tokenIdTracker.current());
        _setTokenURI(_tokenIdTracker.current(),uri);
        _tokenIdTracker.increment();
    }

    function multipleMint(uint256 number,string memory uri) internal onlyOwner {
        uint8[] memory params8 = new uint8[](paramsContract["params8Count"]);
        uint256[] memory params256 = new uint256[](paramsContract["params256Count"]);
        for (uint256 index = 0; index < number; index++) {
            _tokenDetails[_tokenIdTracker.current()] = Token(msg.sender,uri,params8,params256);
            _safeMint(msg.sender, _tokenIdTracker.current());
            _setTokenURI(_tokenIdTracker.current(),uri);
            _tokenIdTracker.increment();
        }
    }

    /**
    Safe transfer one token to another address
     */
    function transfer(address from, address to ,uint256 tokenId) external byDelegate {
        _safeTransfer(from, to, tokenId, "");
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
        Token[] memory result = new Token[](_tokenIdTracker.current());
        for(uint256 i = 0; i < _tokenIdTracker.current(); i++){
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

}

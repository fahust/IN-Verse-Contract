// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import './TokenContract.sol';
import './AuctionContract.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract AuctionController is Ownable {

    
    mapping( string => uint ) paramsContract;//Allows great scalability, you can add or remove as many variables as you want
    mapping( uint256 => AuctionContract ) _auctionContract;
    uint256 countAuctionContract;
    address addressContractToken;


    constructor(address _addressContract) {
        addressContractToken = _addressContract;
    }

    /**
    AUCTION SECTION
     */
    /*function createAuction() external onlyOwner {
        _auctionContract[countAuctionContract] = new AuctionContract(addressContractToken);
        _auctionContract[countAuctionContract].transferOwnership(msg.sender);
        countAuctionContract++;
    }*/

    function getAuctionContract(uint256 i) external view returns(AuctionContract) {
        return AuctionContract(_auctionContract[i]);
    }


    /**
    Get value of one element of array parameter of contract  
    */
    function getParamsContract(string memory keyParams) external view returns (uint256){
        return paramsContract[keyParams];
    }

    /**
    Recover the details of a token by passing its id
     */
    function getTokenDetails(uint256 tokenId) external view returns  (TokenContract.Token memory){
        TokenContract contrat = TokenContract(addressContractToken);
        return contrat.getTokenDetails(tokenId);
    }

    function getAllToken() external view returns (TokenContract.Token[] memory){
        TokenContract contrat = TokenContract(addressContractToken);
        return contrat.getAllToken();
    }

    function lazyMint(string memory uri) payable external{
        TokenContract contrat = TokenContract(addressContractToken);
        uint256 params8Count = contrat.getParamsContract("params8Count");
        uint256 params256Count = contrat.getParamsContract("params256Count");
        uint8[] memory params8 = new uint8[](params8Count);
        uint256[] memory params256 = new uint256[](params256Count);
        contrat.mint(msg.sender, uri, params8, params256);
    }

    /**
    Update address of token
    */
    function setAddressContract(address _addressContract) external onlyOwner {
        addressContractToken = _addressContract;
    }

    /**
    get address of token
    */
    function getAddressContract() external onlyOwner view returns(address) {
        return addressContractToken;
    }


}


// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import './TokenContract.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract AuctionContract is Ownable {


    struct RoyaltiesAddresses {
        address addressRoyalties;
        bool valid;
    }

    struct Bidder {
        address addressBidder;
        uint256 bid;
    }
    
    event Bidders(address indexed addressBidder, uint256 bid);

    mapping( uint8 => RoyaltiesAddresses ) private _addressRoyalties;
    mapping( uint256 => Bidder ) private _bidders;
    mapping( string => uint ) paramsContract;//Allows great scalability, you can add or remove as many variables as you want
    address addressContractToken;
    address lastBidder;
    uint256 countBidder;
    uint8 countAddressRoyalties;
    bool endedAndTransfered;
    bool paused = false;


    constructor(address _addressContract) {
        addressContractToken = _addressContract;
        paramsContract["bid"] = 100000000000000000;//set minimum price
        paramsContract["startAuction"] = 0;//start auction date
        paramsContract["params8Count"] = 5;
        paramsContract["params256Count"] = 5;
        paramsContract["timeAuction"] = 60 minutes;
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

    /**
    Bid for the collection
    Verify that the bidder has sent more ETH than the initial and the last auction
    Check that the auction has started and is not yet finished
     */
    function bidding() payable external {
        require(msg.value>paramsContract["bid"],"Require more ETH for bidding");
        require(paramsContract["startAuction"]!=0,"Auction not started");
        require(block.timestamp<(paramsContract["startAuction"]+paramsContract["timeAuction"]),"Auction is finished");
        paramsContract["bid"] = msg.value;
        _bidders[countBidder] = Bidder(msg.sender,msg.value);
        lastBidder = msg.sender;
        emit Bidders(msg.sender,msg.value);
        countBidder++;
    }

    function getAllBidders() external view returns (Bidder[] memory){
        Bidder[] memory result = new Bidder[](countBidder);
        for(uint256 i = 0; i < countBidder; i++){
            Bidder storage _bidder = _bidders[i];
            result[i] = _bidder;
        }
        return result;
    }

    function lazyMint(string memory uri) payable external{
        uint8[] memory params8 = new uint8[](paramsContract["params8Count"]);
        uint256[] memory params256 = new uint256[](paramsContract["params256Count"]);
        TokenContract contrat = TokenContract(addressContractToken);
        contrat.mint(msg.sender, uri, params8, params256);
    }

    function multipleMint() external onlyOwner {

    }

    function getBidderDetails(uint256 bidderId) external onlyOwner view returns (Bidder memory){
        return _bidders[bidderId];
    }
    
    /**
    Create addresses to which to send royalties and the percentages they will receive
     */
    function setRoyaltiesAdress(address _address) external onlyOwner {
        _addressRoyalties[countAddressRoyalties] = RoyaltiesAddresses(_address,true);
        countAddressRoyalties++;
    }

    /**
    Remove addresses to which to send royalties and the percentages they will receive
     */
    function removeRoyaltiesAdress(address _address) external onlyOwner {
        for (uint8 iRoyalties = 0; iRoyalties <= countAddressRoyalties; iRoyalties++) {
            if(_addressRoyalties[iRoyalties].addressRoyalties == _address){
                _addressRoyalties[iRoyalties].valid = false;
                countAddressRoyalties--;
            }
        }
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
    function getAddressContract(address _addressContract) external onlyOwner view returns(address) {
        return addressContractToken;
    }

    /**
    Update dynamic array of params of this contract
     */
    function setParamsContract(string memory keyParams, uint valueParams) external onlyOwner {
        paramsContract[keyParams] = valueParams;
    }

    /**
    Start the auction now !
     */
    function startAuction() external onlyOwner {
        paramsContract["startAuction"] = block.timestamp;
    }

    /**
    We refund all those who are not the last to bid
    We send the collection to the winner of the auction
    And we send royalties percent at address setted
     */
    function endAuction() external onlyOwner {
        require(block.timestamp>=(paramsContract["startAuction"]+paramsContract["timeAuction"]),"Auction is finished");
        require(endedAndTransfered==false,"collection selled");
        TokenContract contrat = TokenContract(addressContractToken);
        for(uint256 i = 0; i <= countBidder; i++){
            if(lastBidder == _bidders[i].addressBidder){
                for (uint256 iToken = 0; iToken < 10; iToken++) {
                    contrat.transfer(contrat.getOwnerOf(iToken), _bidders[i].addressBidder, iToken);
                }
            }else{
                payable(_bidders[i].addressBidder).transfer(_bidders[i].bid);
            }
        }
        endedAndTransfered = true;
        payRoyalties();
    }

    /**
    Pay royalties
    */
    function payRoyalties() internal {
        uint256 percent = address(this).balance/countAddressRoyalties;
        for (uint8 iRoyalties = 0; iRoyalties <= countAddressRoyalties; iRoyalties++) {
            if(_addressRoyalties[iRoyalties].valid == true){
                payable(_addressRoyalties[iRoyalties].addressRoyalties).transfer(percent);
            }
        }
    }

    /**
    Temporarily lock the contract
     */
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    function kill() external onlyOwner {
        require(block.timestamp<=(paramsContract["startAuction"]+paramsContract["timeAuction"]),"Auction is not finished");
        address payable addr = payable(address(owner()));
        selfdestruct(addr);
    }

    /**
    Handling of funds, just in case
     */
    /*function withdraw() external byOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit(uint256 amount) payable external byOwner {
        require(msg.value == amount);
    }*/

}


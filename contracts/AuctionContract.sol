// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import './TokenContract.sol';
import './Struct.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract AuctionContract is Ownable, Struct {

    mapping( uint256 => Auction ) _auctions;
    uint256 countAuction;
    
    event Bidders(address indexed addressBidder, uint256 bid);
    event Auctions(uint256 indexed id, address owner);

    function createAuction() internal returns(uint256) {
        Auction storage auction = _auctions[countAuction];
        _auctions[countAuction].paramsContract["minBid"] = 100000000000000000;//set minimum price
        _auctions[countAuction].paramsContract["startAuction"] = 0;//start auction date
        _auctions[countAuction].paramsContract["timeAuction"] = 60 minutes;
        _auctions[countAuction].paramsContract["numberTokenEndAuction"] = 1;
        _auctions[countAuction].owner = msg.sender;
        _auctions[countAuction].valid = true;
        countAuction++;
        return countAuction-1;
    }

    /**
    On set le tableau de token dans l'auction avec un tableau directement, plus rapide ,plus opti
     */
    function setTokenInAuction(uint256 a, uint256[] memory arrayToken) external OwnerContract(a) {
        _auctions[a]._tokenInAuction = arrayToken;
    }

    /**
    Pour récuperer le tableau coter front, le mêttre a jour coter front puis renvoyer vers solidity quand on modif
     */
    function getTokenInAuctionArray(uint256 a) external view returns(uint256[] memory) {
        return _auctions[a]._tokenInAuction;
    }

    /*function getTokenInAuction() external view returns(TokenContract.Token) {
        return _auctions[a]._tokenInAuction;
    }*/

    /**
    Get value of one element of array parameter of contract  
    */
    function getParamsContract(uint256 a, string memory keyParams) external view returns (uint256){
        return _auctions[a].paramsContract[keyParams];
    }

    modifier OwnerContract(uint256 a){
        require(msg.sender == _auctions[a].owner,"Your are not the auction owner");
        require(_auctions[a].valid == true,"Auction is not valid");
        _;
    }

    /**
    Bid for the collection
    Verify that the bidder has sent more ETH than the initial and the last auction
    Check that the auction has started and is not yet finished
     */
    function bidding(uint256 a) payable external {
        require(msg.value>_auctions[a].paramsContract["minBid"]&&msg.value>_auctions[a].lastBidder.bid,"Require more ETH for bidding");
        require(_auctions[a].paramsContract["startAuction"]!=0,"Auction not started");
        require(block.timestamp<(_auctions[a].paramsContract["startAuction"]+_auctions[a].paramsContract["timeAuction"]),"Auction is finished");
        //refunded previous bidder
        payable(_auctions[a].lastBidder.addressBidder).transfer(_auctions[a].lastBidder.bid);
        _auctions[a].lastBidder = Bidder(msg.sender,msg.value);
        emit Bidders(msg.sender,msg.value);
    }
    
    /**
    Create addresses to which to send royalties and the percentages they will receive
     */
    function setRoyaltiesAdress(uint256 a, address _address) external OwnerContract(a) {
        _auctions[a]._addressRoyalties[_auctions[a].countAddressRoyalties] = RoyaltiesAddresses(_address,true);
        _auctions[a].countAddressRoyalties++;
    }

    /**
    Remove addresses to which to send royalties and the percentages they will receive
     */
    function removeRoyaltiesAdress(uint256 a, address _address) external OwnerContract(a) {
        for (uint8 iRoyalties = 0; iRoyalties <= _auctions[a].countAddressRoyalties; iRoyalties++) {
            if(_auctions[a]._addressRoyalties[iRoyalties].addressRoyalties == _address){
                _auctions[a]._addressRoyalties[iRoyalties].valid = false;
                _auctions[a].countAddressRoyalties--;
            }
        }
    }

    /**
    Update address of token
    */
    function setAddressContract(uint256 a, address _addressContract) external OwnerContract(a) {
        _auctions[a].addressContractToken = _addressContract;
    }

    /**
    get address of token
    */
    function getAddressContract(uint256 a) external OwnerContract(a) view returns(address) {
        return _auctions[a].addressContractToken;
    }

    /**
    Update dynamic array of params of this contract
     */
    function setParamsContract(uint256 a, string memory keyParams, uint valueParams) external OwnerContract(a) {
        _auctions[a].paramsContract[keyParams] = valueParams;
    }

    /**
    Start the auction now !
     */
    function startAuction(uint256 a) external OwnerContract(a) {
        require(_auctions[a].endedAndTransfered==false,"collection selled");
        _auctions[a].paramsContract["startAuction"] = block.timestamp;
    }

    /**
    We refund all those who are not the last to bid
    We send the collection to the winner of the auction
    And we send royalties percent at address setted
     */
    function endAuction(uint256 a) external OwnerContract(a) {
        require(block.timestamp>=(_auctions[a].paramsContract["startAuction"]+_auctions[a].paramsContract["timeAuction"]),"Auction is not finished");
        require(_auctions[a].endedAndTransfered==false,"collection selled");
        TokenContract contrat = TokenContract(_auctions[a].addressContractToken);
        for (uint256 iToken = 0; iToken < _auctions[a]._tokenInAuction.length; iToken++) {
            contrat.transfer(contrat.getOwnerOf(_auctions[a]._tokenInAuction[iToken]), _auctions[a].lastBidder.addressBidder, _auctions[a]._tokenInAuction[iToken]);
        }
        _auctions[a].endedAndTransfered = true;
        payRoyalties(a);
    }

    /**
    Pay royalties
    */
    function payRoyalties(uint256 a) internal {
        if(_auctions[a].countAddressRoyalties>0){
            uint256 percent = _auctions[a].lastBidder.bid/_auctions[a].countAddressRoyalties;
            for (uint8 iRoyalties = 0; iRoyalties < _auctions[a].countAddressRoyalties; iRoyalties++) {
                if(_auctions[a]._addressRoyalties[iRoyalties].valid == true){
                    payable(_auctions[a]._addressRoyalties[iRoyalties].addressRoyalties).transfer(percent);
                }
            }
        }
    }

    /**
    Temporarily lock the contract
     */
    function pause(uint256 a, bool _state) external onlyOwner {
        _auctions[a].paused = _state;
    }

}


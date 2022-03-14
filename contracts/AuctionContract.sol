// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import './INERC721A.sol';
import './Struct.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract AuctionContract is Ownable, Struct {

    struct List {
        Bidder lastBidder;
        address addressContractToken;
        bool endedAndTransfered;
        RoyaltiesAddresses[] _royalties;
        uint256[] _tokenInAuction;
        uint256[] _priceToken;
        uint256 listingId;
        uint256 minBid;
        uint256 startDate;
        uint256 timeAuction;
        bool paused;
        bool valid;
        bool direct;//false = auction
        uint8 tokenType;
    }
    
    mapping( uint256 => List ) _lists;
    uint256 countList;
    
    event Bidders(address indexed addressBidder, uint256 bid);
    event Auctions(uint256 indexed id, address owner);

    modifier onlyExistingListing(uint256 _listingId) {
        require(_lists[_listingId].addressContractToken != address(0), "listing do not exist");
        _;
    }

    function createList(List memory paramsList) internal onlyOwner returns(uint256) {
        //INERC721A contratToken = INERC721A(paramsList.addressContractToken);
        require(INERC721A(paramsList.addressContractToken).owner()==msg.sender,"This token contract is not yours");
        require(paramsList._tokenInAuction.length==paramsList._tokenInAuction.length,"Token array and token price not valid");
        List memory newListing = List({
            lastBidder: Bidder(address(0),0),
            addressContractToken: paramsList.addressContractToken,
            paused: paramsList.paused,
            valid: paramsList.valid,
            endedAndTransfered:false,
            _royalties: paramsList._royalties,
            _tokenInAuction: paramsList._tokenInAuction,
            _priceToken: paramsList._priceToken,
            listingId: countList,
            minBid: paramsList.minBid,
            startDate: paramsList.startDate,
            timeAuction: paramsList.timeAuction,
            direct: paramsList.direct,
            tokenType: paramsList.tokenType
        });
        _lists[countList] = newListing;
        countList++;
        //validateOwnershipAndApproval
        transferListingTokens(paramsList.addressContractToken,address(this),newListing);
        return countList-1;
    }

    function updateList(List memory paramsList) internal onlyOwner returns(List memory) {
        require(INERC721A(paramsList.addressContractToken).owner()==msg.sender,"This token contract is not yours");
        require(paramsList._tokenInAuction.length==paramsList._tokenInAuction.length,"Token array and token price not valid");

        if (_lists[paramsList.listingId].direct == false) {
            require(block.timestamp < _lists[paramsList.listingId].startDate, "Auction already started.");
            //require(_buyoutPricePerToken >= _reservePricePerToken, "reserve price exceeds buyout price.");
        }
        
        if(keccak256(abi.encodePacked(_lists[paramsList.listingId]._tokenInAuction)) != keccak256(abi.encodePacked(paramsList._tokenInAuction)) || _lists[paramsList.listingId].addressContractToken != paramsList.addressContractToken){
            transferListingTokens(address(this),_lists[paramsList.listingId].addressContractToken,_lists[paramsList.listingId]);
            transferListingTokens(paramsList.addressContractToken,address(this),paramsList);
        }

        _lists[paramsList.listingId] = List({
            lastBidder: _lists[paramsList.listingId].lastBidder,
            addressContractToken: paramsList.addressContractToken,
            paused: paramsList.paused,
            valid: paramsList.valid,
            endedAndTransfered:false,
            _royalties: paramsList._royalties,
            _tokenInAuction: paramsList._tokenInAuction,
            _priceToken: paramsList._priceToken,
            listingId: _lists[paramsList.listingId].listingId,
            minBid: paramsList.minBid,
            startDate: paramsList.startDate,
            timeAuction: paramsList.timeAuction,
            direct: paramsList.direct,
            tokenType: paramsList.tokenType
        });
        //validateOwnershipAndApproval
        return _lists[paramsList.listingId];
    }

    function buy(uint256 _listingId, uint256 tokenId) external payable onlyExistingListing(_listingId) {
        require(msg.value >= _lists[_listingId]._priceToken[tokenId],"Not enought money sended");
        List memory targetListing = _lists[_listingId];
        transferListingTokens(address(this),msg.sender,_lists[_listingId]);
        INERC721A(_lists[_listingId].addressContractToken).safeTransferFrom(address(this), msg.sender, _lists[_listingId]._tokenInAuction[tokenId]);
        delete _lists[_listingId]._tokenInAuction[tokenId];
        delete _lists[_listingId]._priceToken[tokenId];
        if(_lists[_listingId]._tokenInAuction.length<=0) cancelList(_listingId);
    }

    function cancelList(uint256 _listingId) public onlyOwner() {
        transferListingTokens(address(this),_lists[_listingId].addressContractToken,_lists[_listingId]);
        delete _lists[_listingId];
    }

    function getList(uint256 i) external view returns (List memory){
        return _lists[i];
    }

    function getLists() external view returns (List[] memory){
        List[] memory result = new List[](countList);
        for(uint256 i = 0; i < countList; i++){
            List storage _list = _lists[i];
            result[i] = _list;
        }
        return result;
    }

    function transferListingTokens(
        address _from,
        address _to,
        List memory _listing
    ) internal {
        
        if (_listing.tokenType == 1) {
            //INERC1155(_listing.assetContract).safeTransferFrom(_from, _to, _listing.tokenId, _quantity);
        } else if (_listing.tokenType == 2) {
            for (uint256 index = 0; index < _listing._tokenInAuction.length; index++) {
                INERC721A(_listing.addressContractToken).safeTransferFrom(_from, _to, _listing._tokenInAuction[index]);
            }
        }
    }

    /*function getTokenInAuction() external view returns(INERC721A.Token) {
        return _lists[i]._tokenInAuction;
    }*/

    /**
    Bid for the collection
    Verify that the bidder has sent more ETH than the initial and the last auction
    Check that the auction has started and is not yet finished
     */
    function bidding(uint256 i) payable external {
        require(msg.value>_lists[i].minBid&&msg.value>_lists[i].lastBidder.bid,"Require more ETH for bidding");
        require(_lists[i].startDate!=0,"Auction not started");
        require(block.timestamp<(_lists[i].startDate+_lists[i].startDate),"Auction is finished");
        //refunded previous bidder
        payable(_lists[i].lastBidder.addressBidder).transfer(_lists[i].lastBidder.bid);
        _lists[i].lastBidder = Bidder(msg.sender,msg.value);
        emit Bidders(msg.sender,msg.value);
    }

    /**
    We refund all those who are not the last to bid
    We send the collection to the winner of the auction
    And we send royalties percent at address setted
     */
    function endAuction(uint256 i) external onlyOwner() {
        require(block.timestamp>=(_lists[i].startDate+_lists[i].startDate),"List is not finished");
        require(_lists[i].endedAndTransfered==false,"collection selled");
        transferListingTokens(address(this),_lists[i].lastBidder.addressBidder,_lists[i]);
        _lists[i].endedAndTransfered = true;
        payRoyalties(i);
        delete _lists[i];
    }

    /**
    Pay royalties
    */
    function payRoyalties(uint256 i) internal {
        if(_lists[i]._royalties.length>0){
            for (uint8 iRoyalties = 0; iRoyalties < _lists[i]._royalties.length; iRoyalties++) {
                uint256 percent = _lists[i].lastBidder.bid*(_lists[i]._royalties[iRoyalties].percent/100);
                if(_lists[i]._royalties[iRoyalties].addr != address(0)){
                    payable(_lists[i]._royalties[iRoyalties].addr).transfer(percent);
                }
            }
        }
    }

    /**
    Temporarily lock the contract
     */
    /*function pause(uint256 a, bool _state) external onlyOwner {
        _lists[i].paused = _state;
    }*/

}


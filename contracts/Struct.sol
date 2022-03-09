
// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;


contract Struct {
    uint8 private constant MINTER = 1;
    uint8 private constant PAUSER = 2;
    uint8 private constant EDITOR = 3;

    struct RoyaltiesAddresses {
        address addressRoyalties;
        bool valid;
    }

    struct Bidder {
        address addressBidder;
        uint256 bid;
    }

    struct Auction {
        Bidder lastBidder;
        address owner;
        address addressContractToken;
        uint8 countAddressRoyalties;
        bool endedAndTransfered;
        bool paused;
        bool valid;
        string name;
        mapping( uint8 => RoyaltiesAddresses ) _addressRoyalties;
        uint256[] _tokenInAuction;
        mapping( string => uint ) paramsContract;//Allows great scalability, you can add or remove as many variables as you want
    }
    
    struct Account {
        address owner;
        mapping( uint256 => address ) _collections;
        mapping( uint256 => uint256 ) _auctions;
        uint256 countCollection;
        uint256 countAuction;
        uint256[] params256;//Allows great scalability, you can add or remove as many variables as you want
        string[] paramsString;//Allows great scalability, you can add or remove as many variables as you want
        address[] _minter_role;
        address[] _pauser_role;
        address[] _editor_role;

    }
}
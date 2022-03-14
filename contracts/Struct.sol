
// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;


contract Struct {
    uint8 private constant MINTER = 1;
    uint8 private constant PAUSER = 2;
    uint8 private constant EDITOR = 3;

    struct RoyaltiesAddresses {
        address addr;
        uint8 percent;
    }

    struct Bidder {
        address addressBidder;
        uint256 bid;
    }
}
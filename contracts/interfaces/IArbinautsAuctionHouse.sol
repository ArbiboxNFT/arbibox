// SPDX-License-Identifier: MIT

/// @title Interface for Arbinaut Auction Houses



pragma solidity ^0.8.6;

interface IArbinautsAuctionHouse {
    struct Auction {
        // ID for the Arbinaut (ERC721 token ID)
        uint256 arbinautId;
        // The current highest bid amount
        uint256 amount;
        // The time that the auction started
        uint256 startTime;
        // The time that the auction is scheduled to end
        uint256 endTime;
        // The address of the current highest bid
        address payable bidder;
        // Whether or not the auction has been settled
        bool settled;
    }

    event AuctionCreated(uint256 indexed arbinautId, uint256 startTime, uint256 endTime);

    event AuctionBid(uint256 indexed arbinautId, address sender, uint256 value, bool extended);

    event AuctionExtended(uint256 indexed arbinautId, uint256 endTime);

    event AuctionSettled(uint256 indexed arbinautId, address winner, uint256 amount);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    function settleAuction() external;

    function settleCurrentAndCreateNewAuction() external;

    function createBid(uint256 arbinautId) external payable;

    function pause() external;

    function unpause() external;

    function setTimeBuffer(uint256 timeBuffer) external;

    function setReservePrice(uint256 reservePrice) external;

    function setMinBidIncrementPercentage(uint8 minBidIncrementPercentage) external;

    function setArbinautsDev(address _arbinautsDev) external;

    function setArbinautsTreasury(address _arbinautsTreasury) external;

    function setMetatopiaTreasury(address _metatopiaTreasury) external;

    function setMetatopiaPercent(uint16 _metatopiaPercent) external;
}
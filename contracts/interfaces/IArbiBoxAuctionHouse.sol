// SPDX-License-Identifier: MIT

/// @title Interface for ArbiBox Auction Houses



pragma solidity ^0.8.6;

interface IArbiBoxAuctionHouse {
    struct Auction {
        // ID for the ArbiBox (ERC721 token ID)
        uint256 arbiboxId;
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

    event AuctionCreated(uint256 indexed arbiboxId, uint256 startTime, uint256 endTime);

    event AuctionBid(uint256 indexed arbiboxId, address sender, uint256 value, bool extended);

    event AuctionExtended(uint256 indexed arbiboxId, uint256 endTime);

    event AuctionSettled(uint256 indexed arbiboxId, address winner, uint256 amount);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    function settleAuction() external;

    function settleCurrentAndCreateNewAuction() external;

    function createBid(uint256 arbiboxId) external payable;

    function pause() external;

    function unpause() external;

    function setTimeBuffer(uint256 timeBuffer) external;

    function setReservePrice(uint256 reservePrice) external;

    function setMinBidIncrementPercentage(uint8 minBidIncrementPercentage) external;

    function setArbiBoxDev(address _arbiboxDev) external;

    function setArbiBoxTreasury(address _arbiboxTreasury) external;

    function setMetatopiaTreasury(address _metatopiaTreasury) external;

    function setMetatopiaPercent(uint16 _metatopiaPercent) external;
}
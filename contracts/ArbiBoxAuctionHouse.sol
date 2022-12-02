// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { PausableUpgradeable } from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import { ReentrancyGuardUpgradeable } from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import { OwnableUpgradeable } from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { IArbiBoxAuctionHouse } from './interfaces/IArbiBoxAuctionHouse.sol';
import { IArbiBoxToken } from './interfaces/IArbiBoxToken.sol';
import { IWETH } from './interfaces/IWETH.sol';

contract ArbiBoxAuctionHouse is IArbiBoxAuctionHouse, PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    // The ArbiBox ERC721 token contract
    IArbiBoxToken public arbibox;

    // The address of the WETH contract
    address public weth;

    // The address of the ArbiBox Dev
    address public arbiboxDev;

    // The address of the ArbiBox Treasury
    address public arbiboxTreasury;

    // The address of the Metatopia Treasury
    address public metatopiaTreasury;

    uint16 public metatopiaPercent;

    // The minimum amount of time left in an auction after a new bid is created
    uint256 public timeBuffer;

    // The minimum price accepted in an auction
    uint256 public reservePrice;

    // The minimum percentage difference between the last bid amount and the current bid
    uint8 public minBidIncrementPercentage;

    // The duration of a single auction
    uint256 public duration;

    // The active auction
    IArbiBoxAuctionHouse.Auction public auction;

    /**
     * @notice Initialize the auction house and base contracts,
     * populate configuration values, and pause the contract.
     * @dev This function can only be called once.
     */
    function initialize(
        IArbiBoxToken _arbibox,
        address _weth,
        address _arbiboxDev,
        address _arbiboxTreasury,
        address _metatopiaTreasury,
        uint16 _metatopiaPercent,
        uint256 _timeBuffer,
        uint256 _reservePrice,
        uint8 _minBidIncrementPercentage,
        uint256 _duration
    ) external initializer {
        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init();

        _pause();

        arbibox = _arbibox;
        weth = _weth;
        arbiboxDev = _arbiboxDev;
        arbiboxTreasury = _arbiboxTreasury;
        metatopiaTreasury = _metatopiaTreasury;
        metatopiaPercent = _metatopiaPercent;
        timeBuffer = _timeBuffer;
        reservePrice = _reservePrice;
        minBidIncrementPercentage = _minBidIncrementPercentage;
        duration = _duration;
    }

    /**
     * @notice Settle the current auction, mint a new ArbiBox, and put it up for auction.
     */
    function settleCurrentAndCreateNewAuction() external override nonReentrant whenNotPaused {
        _settleAuction();
        _createAuction();
    }

    /**
     * @notice Settle the current auction.
     * @dev This function can only be called when the contract is paused.
     */
    function settleAuction() external override whenPaused nonReentrant {
        _settleAuction();
    }

    /**
     * @notice Create a bid for a ArbiBox, with a given amount.
     * @dev This contract only accepts payment in ETH.
     */
    function createBid(uint256 arbiboxId) external payable override nonReentrant {
        IArbiBoxAuctionHouse.Auction memory _auction = auction;

        require(_auction.arbiboxId == arbiboxId, 'Lil ArbiBox not up for auction');
        require(block.timestamp < _auction.endTime, 'Auction expired');
        require(msg.value >= reservePrice, 'Must send at least reservePrice');
        require(
            msg.value >= _auction.amount + ((_auction.amount * minBidIncrementPercentage) / 100),
            'Must send more than last bid by minBidIncrementPercentage amount'
        );

        address payable lastBidder = _auction.bidder;

        // Refund the last bidder, if applicable
        if (lastBidder != address(0)) {
            _safeTransferETHWithFallback(lastBidder, _auction.amount);
        }

        auction.amount = msg.value;
        auction.bidder = payable(msg.sender);

        // Extend the auction if the bid was received within `timeBuffer` of the auction end time
        bool extended = _auction.endTime - block.timestamp < timeBuffer;
        if (extended) {
            auction.endTime = _auction.endTime = block.timestamp + timeBuffer;
        }

        emit AuctionBid(_auction.arbiboxId, msg.sender, msg.value, extended);

        if (extended) {
            emit AuctionExtended(_auction.arbiboxId, _auction.endTime);
        }
    }

    /**
     * @notice Pause the ArbiBox auction house.
     * @dev This function can only be called by the owner when the
     * contract is unpaused. While no new auctions can be started when paused,
     * anyone can settle an ongoing auction.
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the ArbiBox auction house.
     * @dev This function can only be called by the owner when the
     * contract is paused. If required, this function will start a new auction.
     */
    function unpause() external override onlyOwner {
        _unpause();

        if (auction.startTime == 0 || auction.settled) {
            _createAuction();
        }
    }

    /**
     * @notice Set the auction time buffer.
     * @dev Only callable by the owner.
     */
    function setTimeBuffer(uint256 _timeBuffer) external override onlyOwner {
        timeBuffer = _timeBuffer;

        emit AuctionTimeBufferUpdated(_timeBuffer);
    }

    /**
     * @notice Set the auction reserve price.
     * @dev Only callable by the owner.
     */
    function setReservePrice(uint256 _reservePrice) external override onlyOwner {
        reservePrice = _reservePrice;

        emit AuctionReservePriceUpdated(_reservePrice);
    }

    /**
     * @notice Set the auction minimum bid increment percentage.
     * @dev Only callable by the owner.
     */
    function setMinBidIncrementPercentage(uint8 _minBidIncrementPercentage) external override onlyOwner {
        minBidIncrementPercentage = _minBidIncrementPercentage;

        emit AuctionMinBidIncrementPercentageUpdated(_minBidIncrementPercentage);
    }

    function setArbiBoxDev(address _arbiboxDev) external override onlyOwner {
        arbiboxDev = _arbiboxDev;
    }

    function setArbiBoxTreasury(address _arbiboxTreasury) external override onlyOwner {
        arbiboxTreasury = _arbiboxTreasury;
    }

    function setMetatopiaTreasury(address _metatopiaTreasury) external override onlyOwner {
        metatopiaTreasury = _metatopiaTreasury;
    }

    function setMetatopiaPercent(uint16 _metatopiaPercent) external override onlyOwner {
        metatopiaPercent = _metatopiaPercent;
    }

    /**
     * @notice Create an auction.
     * @dev Store the auction details in the `auction` state variable and emit an AuctionCreated event.
     * If the mint reverts, the minter was updated without pausing this contract first. To remedy this,
     * catch the revert and pause this contract.
     */
    function _createAuction() internal {
        try arbibox.mint() returns (uint256 arbiboxId) {
            uint256 startTime = block.timestamp;
            uint256 endTime = startTime + duration;

            auction = Auction({
                arbiboxId: arbiboxId,
                amount: 0,
                startTime: startTime,
                endTime: endTime,
                bidder: payable(0),
                settled: false
            });

            emit AuctionCreated(arbiboxId, startTime, endTime);
        } catch Error(string memory) {
            _pause();
        }
    }

    /**
     * @notice Settle an auction, finalizing the bid and paying out to the owner.
     * @dev If there are no bids, the ArbiBox is burned.
     */
    function _settleAuction() internal {
        IArbiBoxAuctionHouse.Auction memory _auction = auction;

        require(_auction.startTime != 0, "Auction hasn't begun");
        require(!_auction.settled, 'Auction has already been settled');
        require(block.timestamp >= _auction.endTime, "Auction hasn't completed");

        auction.settled = true;

        if (_auction.bidder == address(0)) {
            arbibox.burn(_auction.arbiboxId);
        } else {
            arbibox.transferFrom(address(this), _auction.bidder, _auction.arbiboxId);
        }

        if (_auction.amount > 0) {
            if (_auction.arbiboxId % 10 == 0) {
                _safeTransferETHWithFallback(arbiboxDev, _auction.amount);
            } else if (metatopiaPercent > 0) {
                uint256 metatopiaAmount = _auction.amount * metatopiaPercent / 10000;
                uint256 arbiboxAmount = _auction.amount - metatopiaAmount;
                _safeTransferETHWithFallback(arbiboxTreasury, arbiboxAmount);
                _safeTransferETHWithFallback(metatopiaTreasury, metatopiaAmount);
            } else {
                _safeTransferETHWithFallback(arbiboxTreasury, _auction.amount);
            }
        }

        emit AuctionSettled(_auction.arbiboxId, _auction.bidder, _auction.amount);
    }

    /**
     * @notice Transfer ETH. If the ETH transfer fails, wrap the ETH and try send it as WETH.
     */
    function _safeTransferETHWithFallback(address to, uint256 amount) internal {
        if (!_safeTransferETH(to, amount)) {
            IWETH(weth).deposit{ value: amount }();
            IERC20(weth).transfer(to, amount);
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     * @dev This function only forwards 30,000 gas to the callee.
     */
    function _safeTransferETH(address to, uint256 value) internal returns (bool) {
        (bool success, ) = to.call{ value: value, gas: 30_000 }(new bytes(0));
        return success;
    }
}
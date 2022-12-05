// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IBOXU.sol";
import "./interfaces/IArbinautsToken.sol";

contract Garage is Ownable, ReentrancyGuard {

    IBoxu private BoxuInterface;
    IArbinautsToken private ArbinautsInterface;
    uint256 public dailyBoxu;
    uint80 public minimumStakeTime; // unix timestamp in seconds

    mapping(uint16 => bool) public StakedAndLocked; // whether or not NFT ID is staked
    mapping(uint16 => stakedNFT) public StakedNFTInfo; // tok ID to struct
    mapping(uint16 => uint8) public NFTMultiplier;
    mapping(uint8 => uint16) public multiplier;

    struct stakedNFT {
        uint16 id;
        uint80 stakedTimestamp;
        uint80 lastClaimTimestamp;
    }

     // @param minStakeTime is block timestamp in seconds
    constructor(uint80 _minStakeTime, address _boxu, address _arbinauts) {
        minimumStakeTime = _minStakeTime;
        dailyBoxu = 10*10**18;
        BoxuInterface = IBoxu(_boxu);
        ArbinautsInterface = IArbinautsToken(_arbinauts);

        multiplier[0] = 15000;
        multiplier[1] = 10000;
        multiplier[2] = 10000;
        multiplier[3] = 35000;
        multiplier[4] = 20000;
        multiplier[5] = 10000;
        multiplier[6] = 10000;
        multiplier[7] = 10000;
        multiplier[8] = 10000;
        multiplier[9] = 10000;
        multiplier[10] = 10000;
        multiplier[11] = 25000;
        multiplier[12] = 10000;
        multiplier[13] = 10000;
    }

    event ArbinautsStaked(address indexed staker, uint16[] stakedIDs);
    event ArbinautsUnstaked(address indexed unstaker, uint16[] stakedIDs);
    event BoxuClaimed(address indexed claimer, uint256 amount);

    function setDailyBoxu(uint256 _dailyBoxu) external onlyOwner {
        dailyBoxu = _dailyBoxu;
    }
    
    function setMultipliers(
        uint16 boxuy,
        uint16 bathroom,
        uint16 garage,
        uint16 vault) external onlyOwner {

            multiplier[0] = bathroom;
            multiplier[3] = boxuy;
            multiplier[4] = garage;
            multiplier[11] = vault;
    }

    function setSingleMultiplier(uint8 _index, uint16 _mult) external onlyOwner {
        multiplier[_index] = _mult;
    }

    function stakeAndLock(uint16[] calldata _ids) external nonReentrant {
        uint16 length = uint16(_ids.length);
        for (uint16 i = 0; i < length; i++) {
            require(!StakedAndLocked[_ids[i]], 
            "Already Staked");
            require(msg.sender == ArbinautsInterface.ownerOf(_ids[i]), "Not owner of Arbinaut");
            StakedAndLocked[_ids[i]] = true;
            StakedNFTInfo[_ids[i]].id = _ids[i];
            StakedNFTInfo[_ids[i]].stakedTimestamp = uint80(block.timestamp);
            StakedNFTInfo[_ids[i]].lastClaimTimestamp = uint80(block.timestamp);
            NFTMultiplier[_ids[i]] = ArbinautsInterface.stakeAndLock(_ids[i]);
        }
        emit ArbinautsStaked(msg.sender, _ids);
    }

    function claimBoxu(uint16[] calldata _ids) external nonReentrant {
        uint16 length = uint16(_ids.length);
        uint256 owed;
        for (uint16 i = 0; i < length; i++) {
            require(StakedAndLocked[_ids[i]], 
            "NFT is not staked");
            require(msg.sender == ArbinautsInterface.ownerOf(_ids[i]), "Not owner of Arbinaut");
            owed += ((((block.timestamp - StakedNFTInfo[_ids[i]].lastClaimTimestamp) * dailyBoxu) 
            / 86400) * multiplier[NFTMultiplier[_ids[i]]]) / 10000;
            StakedNFTInfo[_ids[i]].lastClaimTimestamp = uint80(block.timestamp);
        }
        BoxuInterface.mint(msg.sender, owed);
        emit BoxuClaimed(msg.sender, owed);
    }

    function getUnclaimedBoxu(uint16[] calldata _ids) external view returns (uint256 owed, uint256[] memory boxuPerNFTList) {
        uint16 length = uint16(_ids.length);
        uint256 tokenBoxuValue; // amount owed for each individual token in the calldata array
        boxuPerNFTList = new uint256[](length); 
        for (uint16 i = 0; i < length; i++) {
            require(StakedAndLocked[_ids[i]], 
            "NFT is not staked");

            tokenBoxuValue = ((((block.timestamp - StakedNFTInfo[_ids[i]].lastClaimTimestamp) * dailyBoxu) 
            / 86400) * multiplier[NFTMultiplier[_ids[i]]]) / 10000;

            owed += tokenBoxuValue;

            boxuPerNFTList[i] = tokenBoxuValue;
        }
        return (owed, boxuPerNFTList);
    }

    function isNFTStaked(uint16 _id) external view returns (bool) {
        return StakedAndLocked[_id];
    }

    function unstake(uint16[] calldata _ids) external nonReentrant {
        uint16 length = uint16(_ids.length);
        uint256 owed;
        for (uint16 i = 0; i < length; i++) {
            require(StakedAndLocked[_ids[i]], 
            "NFT is not staked");
            require(msg.sender == ArbinautsInterface.ownerOf(_ids[i]), "Not owner of Arbinaut");
            require(block.timestamp - StakedNFTInfo[_ids[i]].stakedTimestamp >= minimumStakeTime, 
            "Must wait min stake time");
            owed += ((((block.timestamp - StakedNFTInfo[_ids[i]].lastClaimTimestamp) * dailyBoxu) 
            / 86400) * multiplier[NFTMultiplier[_ids[i]]]) / 10000;
            ArbinautsInterface.unstakeAndUnlock(_ids[i]);
            delete StakedNFTInfo[_ids[i]];
            StakedAndLocked[_ids[i]] = false;
        }
        BoxuInterface.mint(msg.sender, owed);
        emit BoxuClaimed(msg.sender, owed);
        emit ArbinautsUnstaked(msg.sender, _ids);
    }
}
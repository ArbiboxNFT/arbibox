// SPDX-License-Identifier: MIT

/// @title Interface for ArbinautsToken



pragma solidity ^0.8.6;

import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { IArbinautsDescriptor } from './IArbinautsDescriptor.sol';
import { IArbinautsSeeder } from './IArbinautsSeeder.sol';

interface IArbinautsToken is IERC721 {
    event ArbinautCreated(uint256 indexed tokenId, IArbinautsSeeder.Seed seed);

    event ArbinautBurned(uint256 indexed tokenId);

    event ArbinautStakedAndLocked(uint256 indexed tokenId, uint256 timestamp);

    event ArbinautUnstakedAndUnlocked(uint256 indexed tokenId, uint256 timestamp);

    event ArbinautsTreasuryUpdated(address arbinautsTreasury);

    event MinterUpdated(address minter);

    event MinterLocked();

    event GarageUpdated(address garage);

    event DescriptorUpdated(IArbinautsDescriptor descriptor);

    event DescriptorLocked();

    event SeederUpdated(IArbinautsSeeder seeder);

    event SeederLocked();

    function mint() external returns (uint256);

    function burn(uint256 tokenId) external;

    function dataURI(uint256 tokenId) external returns (string memory);

    function setArbinautsTreasury(address arbinautsTreasury) external;

    function setMinter(address minter) external;

    function lockMinter() external;

    function setDescriptor(IArbinautsDescriptor descriptor) external;

    function lockDescriptor() external;

    function setSeeder(IArbinautsSeeder seeder) external;

    function lockSeeder() external;

    function stakeAndLock(uint256 tokenId) external returns (uint8);

    function unstakeAndUnlock(uint256 tokenId) external;

    function setGarage(address _garage, bool _flag) external;
}
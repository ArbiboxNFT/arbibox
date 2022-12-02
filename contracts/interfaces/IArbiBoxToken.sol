// SPDX-License-Identifier: MIT

/// @title Interface for ArbiBoxToken



pragma solidity ^0.8.6;

import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { IArbiBoxDescriptor } from './IArbiBoxDescriptor.sol';
import { IArbiBoxSeeder } from './IArbiBoxSeeder.sol';

interface IArbiBoxToken is IERC721 {
    event ArbiBoxCreated(uint256 indexed tokenId, IArbiBoxSeeder.Seed seed);

    event ArbiBoxBurned(uint256 indexed tokenId);

    event ArbiBoxStakedAndLocked(uint256 indexed tokenId, uint256 timestamp);

    event ArbiBoxUnstakedAndUnlocked(uint256 indexed tokenId, uint256 timestamp);

    event ArbiBoxTreasuryUpdated(address arbiboxTreasury);

    event MinterUpdated(address minter);

    event MinterLocked();

    event GarageUpdated(address garage);

    event DescriptorUpdated(IArbiBoxDescriptor descriptor);

    event DescriptorLocked();

    event SeederUpdated(IArbiBoxSeeder seeder);

    event SeederLocked();

    function mint() external returns (uint256);

    function burn(uint256 tokenId) external;

    function dataURI(uint256 tokenId) external returns (string memory);

    function setArbiBoxTreasury(address arbiboxTreasury) external;

    function setMinter(address minter) external;

    function lockMinter() external;

    function setDescriptor(IArbiBoxDescriptor descriptor) external;

    function lockDescriptor() external;

    function setSeeder(IArbiBoxSeeder seeder) external;

    function lockSeeder() external;

    function stakeAndLock(uint256 tokenId) external returns (uint8);

    function unstakeAndUnlock(uint256 tokenId) external;

    function setGarage(address _garage, bool _flag) external;
}
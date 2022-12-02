// SPDX-License-Identifier: MIT

/// @title Interface for ArbiBoxDescriptor

pragma solidity ^0.8.6;

import { IArbiBoxDescriptor } from './IArbiBoxDescriptor.sol';

interface IArbiBoxSeeder {
    struct Seed {
        uint48 background;
        uint48 body;
        uint48 accessory;
        uint48 head;
        uint48 eyes;
        uint48 mouth;
    }

    function generateSeed(uint256 arbiboxId, IArbiBoxDescriptor descriptor) external view returns (Seed memory);
}
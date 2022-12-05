// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IArbinautsDescriptor } from './IArbinautsDescriptor.sol';

interface IArbinautsSeeder {
    struct Seed {
        uint48 background;
        uint48 body;
        uint48 accessory;
        uint48 head;
        uint48 eyes;
        uint48 mouth;
    }

    function generateSeed(uint256 arbinautId, IArbinautsDescriptor descriptor) external view returns (Seed memory);
}
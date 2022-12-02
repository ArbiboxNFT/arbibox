// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IBoxDescriptor } from './IBoxDescriptor.sol';

interface IBoxSeeder {
    struct Seed {
        uint48 background;
        uint48 body;
        uint48 accessory;
        uint48 head;
        uint48 eyes;
        uint48 mouth;
    }

    function generateSeed(uint256 boxId, IBoxDescriptor descriptor) external view returns (Seed memory);
}
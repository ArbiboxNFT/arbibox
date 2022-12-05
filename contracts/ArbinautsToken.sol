// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { ERC721Checkpointable } from './base/ERC721Checkpointable.sol';
import { IArbinautsDescriptor } from './interfaces/IArbinautsDescriptor.sol';
import { IArbinautsSeeder } from './interfaces/IArbinautsSeeder.sol';
import { IArbinautsToken } from './interfaces/IArbinautsToken.sol';
import { ERC721 } from './base/ERC721.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';

contract ArbinautsToken is IArbinautsToken, Ownable, ERC721Checkpointable {
    // The arbinautsTreasury address
    address public arbinautsTreasury;

    // An address who has permissions to mint Arbinauts
    address public minter;

    // An address who has permissions to lock and unlock Arbinauts
    mapping(address => bool) public garage;

    // The Arbinauts token URI descriptor
    IArbinautsDescriptor public descriptor;

    // The Arbinauts token seeder
    IArbinautsSeeder public seeder;

    // Whether the minter can be updated
    bool public isMinterLocked;

    // Whether the descriptor can be updated
    bool public isDescriptorLocked;

    // Whether the seeder can be updated
    bool public isSeederLocked;

    // The arbinaut seeds
    mapping(uint256 => IArbinautsSeeder.Seed) public seeds;

    // The internal arbinaut ID tracker
    uint256 private _currentArbinautId = 1;

    // IPFS content hash of contract-level metadata
    string private _contractURIHash = 'QmeaKx7er3tEgmc4vfCAu9Jus9yVWV8KMydpmbupSKSuJ1';

    // OpenSea's Proxy Registry
    IProxyRegistry public immutable proxyRegistry;

    /**
     * @notice Require that the minter has not been locked.
     */
    modifier whenMinterNotLocked() {
        require(!isMinterLocked, 'Minter is locked');
        _;
    }

    /**
     * @notice Require that the descriptor has not been locked.
     */
    modifier whenDescriptorNotLocked() {
        require(!isDescriptorLocked, 'Descriptor is locked');
        _;
    }

    /**
     * @notice Require that the seeder has not been locked.
     */
    modifier whenSeederNotLocked() {
        require(!isSeederLocked, 'Seeder is locked');
        _;
    }

    /**
     * @notice Require that the sender is the arbinauts Treasury.
     */
    modifier onlyArbinautsTreasury() {
        require(msg.sender == arbinautsTreasury, 'Sender is not the arbinauts Treasury');
        _;
    }

    /**
     * @notice Require that the sender is the minter.
     */
    modifier onlyMinter() {
        require(msg.sender == minter, 'Sender is not the minter');
        _;
    }

    /**
     * @notice Require that the sender is the garage.
     */
    modifier onlyGarage() {
        require(garage[msg.sender], 'Sender is not the garage');
        _;
    }

    constructor(
        address _arbinautsTreasury,
        address _minter,
        IArbinautsDescriptor _descriptor,
        IArbinautsSeeder _seeder,
        IProxyRegistry _proxyRegistry
    ) ERC721("Arbinauts", "ARBINAUTS") {
        arbinautsTreasury = _arbinautsTreasury;
        minter = _minter;
        descriptor = _descriptor;
        seeder = _seeder;
        proxyRegistry = _proxyRegistry;
    }

    /**
     * @notice The IPFS URI of contract-level metadata.
     */
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked('ipfs://', _contractURIHash));
    }

    /**
     * @notice Set the _contractURIHash.
     * @dev Only callable by the owner.
     */
    function setContractURIHash(string memory newContractURIHash) external onlyOwner {
        _contractURIHash = newContractURIHash;
    }

    /**
     * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator) public view override(IERC721, ERC721) returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        if (proxyRegistry.proxies(owner) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    function stakeAndLock(uint256 tokenId) external override onlyGarage returns (uint8) {
        require(tx.origin == ownerOf(tokenId), 'Not owner of Arbinaut');

        isStakedAndLocked[tokenId] = true;

        emit ArbinautStakedAndLocked(tokenId, block.timestamp);
        return uint8(seeds[tokenId].background);
    }

    function unstakeAndUnlock(uint256 tokenId) external override onlyGarage {
        require(tx.origin == ownerOf(tokenId), 'Not owner of Arbinaut');
        
        isStakedAndLocked[tokenId] = false;

        emit ArbinautUnstakedAndUnlocked(tokenId, block.timestamp);
    }

    /**
     * @notice Mint a Arbinaut to the minter.
     * @dev Call _mintTo with the to address(es).
     */
    function mint() public override onlyMinter returns (uint256) {
        return _mintTo(minter, _currentArbinautId++);
    }

    /**
     * @notice Burn a arbinaut.
     */
    function burn(uint256 arbinautId) public override onlyMinter {
        _burn(arbinautId);
        emit ArbinautBurned(arbinautId);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'ArbinautsToken: URI query for nonexistent token');
        return descriptor.tokenURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     */
    function dataURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'ArbinautsToken: URI query for nonexistent token');
        return descriptor.dataURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Set the arbinauts Treasury.
     * @dev Only callable by the arbinauts Treasury when not locked.
     */
    function setArbinautsTreasury(address _arbinautsTreasury) external override onlyArbinautsTreasury {
        arbinautsTreasury = _arbinautsTreasury;

        emit ArbinautsTreasuryUpdated(_arbinautsTreasury);
    }

    /**
     * @notice Set the token minter.
     * @dev Only callable by the owner when not locked.
     */
    function setMinter(address _minter) external override onlyOwner whenMinterNotLocked {
        minter = _minter;

        emit MinterUpdated(_minter);
    }

    function setGarage(address _garage, bool _flag) external override onlyOwner {
        garage[_garage] = _flag;

        emit GarageUpdated(_garage);
    }

    /**
     * @notice Lock the minter.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockMinter() external override onlyOwner whenMinterNotLocked {
        isMinterLocked = true;

        emit MinterLocked();
    }

    /**
     * @notice Set the token URI descriptor.
     * @dev Only callable by the owner when not locked.
     */
    function setDescriptor(IArbinautsDescriptor _descriptor) external override onlyOwner whenDescriptorNotLocked {
        descriptor = _descriptor;

        emit DescriptorUpdated(_descriptor);
    }

    /**
     * @notice Lock the descriptor.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockDescriptor() external override onlyOwner whenDescriptorNotLocked {
        isDescriptorLocked = true;

        emit DescriptorLocked();
    }

    /**
     * @notice Set the token seeder.
     * @dev Only callable by the owner when not locked.
     */
    function setSeeder(IArbinautsSeeder _seeder) external override onlyOwner whenSeederNotLocked {
        seeder = _seeder;

        emit SeederUpdated(_seeder);
    }

    /**
     * @notice Lock the seeder.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockSeeder() external override onlyOwner whenSeederNotLocked {
        isSeederLocked = true;

        emit SeederLocked();
    }

    /**
     * @notice Mint a Arbinaut with `arbinautId` to the provided `to` address.
     */
    function _mintTo(address to, uint256 arbinautId) internal returns (uint256) {
        IArbinautsSeeder.Seed memory seed = seeds[arbinautId] = seeder.generateSeed(arbinautId, descriptor);

        _mint(owner(), to, arbinautId);
        emit ArbinautCreated(arbinautId, seed);

        return arbinautId;
    }
}
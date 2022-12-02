// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { ERC721Checkpointable } from './base/ERC721Checkpointable.sol';
import { IArbiBoxDescriptor } from './interfaces/IArbiBoxDescriptor.sol';
import { IArbiBoxSeeder } from './interfaces/IArbiBoxSeeder.sol';
import { IArbiBoxToken } from './interfaces/IArbiBoxToken.sol';
import { ERC721 } from './base/ERC721.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';

contract ArbiBoxToken is IArbiBoxToken, Ownable, ERC721Checkpointable {
    // The arbiboxTreasury address
    address public arbiboxTreasury;

    // An address who has permissions to mint ArbiBox
    address public minter;

    // An address who has permissions to lock and unlock ArbiBox
    mapping(address => bool) public garage;

    // The ArbiBox token URI descriptor
    IArbiBoxDescriptor public descriptor;

    // The ArbiBox token seeder
    IArbiBoxSeeder public seeder;

    // Whether the minter can be updated
    bool public isMinterLocked;

    // Whether the descriptor can be updated
    bool public isDescriptorLocked;

    // Whether the seeder can be updated
    bool public isSeederLocked;

    // The arbibox seeds
    mapping(uint256 => IArbiBoxSeeder.Seed) public seeds;

    // The internal arbibox ID tracker
    uint256 private _currentArbiBoxId = 1;

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
     * @notice Require that the sender is the arbibox Treasury.
     */
    modifier onlyArbiBoxTreasury() {
        require(msg.sender == arbiboxTreasury, 'Sender is not the arbibox Treasury');
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
        address _arbiboxTreasury,
        address _minter,
        IArbiBoxDescriptor _descriptor,
        IArbiBoxSeeder _seeder,
        IProxyRegistry _proxyRegistry
    ) ERC721("ArbiBox", "SWEEPER") {
        arbiboxTreasury = _arbiboxTreasury;
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
        require(tx.origin == ownerOf(tokenId), 'Not owner of ArbiBox');

        isStakedAndLocked[tokenId] = true;

        emit ArbiBoxStakedAndLocked(tokenId, block.timestamp);
        return uint8(seeds[tokenId].background);
    }

    function unstakeAndUnlock(uint256 tokenId) external override onlyGarage {
        require(tx.origin == ownerOf(tokenId), 'Not owner of ArbiBox');
        
        isStakedAndLocked[tokenId] = false;

        emit ArbiBoxUnstakedAndUnlocked(tokenId, block.timestamp);
    }

    /**
     * @notice Mint a ArbiBox to the minter.
     * @dev Call _mintTo with the to address(es).
     */
    function mint() public override onlyMinter returns (uint256) {
        return _mintTo(minter, _currentArbiBoxId++);
    }

    /**
     * @notice Burn a arbibox.
     */
    function burn(uint256 arbiboxId) public override onlyMinter {
        _burn(arbiboxId);
        emit ArbiBoxBurned(arbiboxId);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'ArbiBoxToken: URI query for nonexistent token');
        return descriptor.tokenURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     */
    function dataURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'ArbiBoxToken: URI query for nonexistent token');
        return descriptor.dataURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Set the arbibox Treasury.
     * @dev Only callable by the arbibox Treasury when not locked.
     */
    function setArbiBoxTreasury(address _arbiboxTreasury) external override onlyArbiBoxTreasury {
        arbiboxTreasury = _arbiboxTreasury;

        emit ArbiBoxTreasuryUpdated(_arbiboxTreasury);
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
    function setDescriptor(IArbiBoxDescriptor _descriptor) external override onlyOwner whenDescriptorNotLocked {
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
    function setSeeder(IArbiBoxSeeder _seeder) external override onlyOwner whenSeederNotLocked {
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
     * @notice Mint a ArbiBox with `arbiboxId` to the provided `to` address.
     */
    function _mintTo(address to, uint256 arbiboxId) internal returns (uint256) {
        IArbiBoxSeeder.Seed memory seed = seeds[arbiboxId] = seeder.generateSeed(arbiboxId, descriptor);

        _mint(owner(), to, arbiboxId);
        emit ArbiBoxCreated(arbiboxId, seed);

        return arbiboxId;
    }
}
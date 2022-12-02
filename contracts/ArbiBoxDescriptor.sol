// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import { IArbiBoxDescriptor } from './interfaces/IArbiBoxDescriptor.sol';
import { IArbiBoxSeeder } from './interfaces/IArbiBoxSeeder.sol';
import { NFTDescriptor } from './libraries/NFTDescriptor.sol';
import { MultiPartRLEToSVG } from './libraries/MultiPartRLEToSVG.sol';

contract ArbiBoxDescriptor is IArbiBoxDescriptor, Ownable {
    using Strings for uint256;

    // Whether or not new ArbiBox parts can be added
    bool public override arePartsLocked;

    // Whether or not `tokenURI` should be returned as a data URI (Default: true)
    bool public override isDataURIEnabled = true;

    // Base URI
    string public override baseURI;

    // ArbiBox Color Palettes (Index => Hex Colors)
    mapping(uint8 => string[]) public override palettes;

    // ArbiBox Backgrounds (Hex Colors)
    string[] public override bgColors;

    // ArbiBox Backgrounds (Hex Colors)
    bytes[] public override backgrounds;

    // ArbiBox Bodies (Custom RLE)
    bytes[] public override bodies;

    // ArbiBox Accessories (Custom RLE)
    bytes[] public override accessories;

    // ArbiBox Heads (Custom RLE)
    bytes[] public override heads;

    // ArbiBox Eyes (Custom RLE)
    bytes[] public override eyes;

    // ArbiBox Eyes (Custom RLE)
    bytes[] public override mouths;

    // ArbiBox Backgrounds (Hex Colors)
    string[] public override backgroundNames;

    // ArbiBox Bodies (Custom RLE)
    string[] public override bodyNames;

    // ArbiBox Accessories (Custom RLE)
    string[] public override accessoryNames;

    // ArbiBox Heads (Custom RLE)
    string[] public override headNames;

    // ArbiBox Eyes (Custom RLE)
    string[] public override eyesNames;

    // ArbiBox Eyes (Custom RLE)
    string[] public override mouthNames;

    /**
     * @notice Require that the parts have not been locked.
     */
    modifier whenPartsNotLocked() {
        require(!arePartsLocked, 'Parts are locked');
        _;
    }

    /**
     * @notice Get the number of available ArbiBox `backgrounds`.
     */
    function backgroundCount() external view override returns (uint256) {
        return backgrounds.length;
    }

    /**
     * @notice Get the number of available ArbiBox `backgrounds`.
     */
    function bgColorsCount() external view override returns (uint256) {
        return bgColors.length;
    }

    /**
     * @notice Get the number of available ArbiBox `bodies`.
     */
    function bodyCount() external view override returns (uint256) {
        return bodies.length;
    }

    /**
     * @notice Get the number of available ArbiBox `accessories`.
     */
    function accessoryCount() external view override returns (uint256) {
        return accessories.length;
    }

    /**
     * @notice Get the number of available ArbiBox `heads`.
     */
    function headCount() external view override returns (uint256) {
        return heads.length;
    }

    /**
     * @notice Get the number of available ArbiBox `eyes`.
     */
    function eyesCount() external view override returns (uint256) {
        return eyes.length;
    }

    /**
     * @notice Get the number of available ArbiBox `mouths`.
     */
    function mouthCount() external view override returns (uint256) {
        return mouths.length;
    }

    /**
     * @notice Add colors to a color palette.
     * @dev This function can only be called by the owner.
     */
    function addManyColorsToPalette(uint8 paletteIndex, string[] calldata newColors) external override onlyOwner {
        require(palettes[paletteIndex].length + newColors.length <= 264, 'Palettes can only hold 265 colors');
        for (uint256 i = 0; i < newColors.length; i++) {
            _addColorToPalette(paletteIndex, newColors[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox backgrounds.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyBgColors(string[] calldata _bgColors) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _bgColors.length; i++) {
            _addBgColor(_bgColors[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox backgrounds.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyBackgrounds(bytes[] calldata _backgrounds) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _backgrounds.length; i++) {
            _addBackground(_backgrounds[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox bodies.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyBodies(bytes[] calldata _bodies) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _bodies.length; i++) {
            _addBody(_bodies[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox accessories.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyAccessories(bytes[] calldata _accessories) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _accessories.length; i++) {
            _addAccessory(_accessories[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox heads.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyHeads(bytes[] calldata _heads) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _heads.length; i++) {
            _addHead(_heads[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox eyes.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyEyes(bytes[] calldata _eyes) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _eyes.length; i++) {
            _addEyes(_eyes[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox mouths.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyMouths(bytes[] calldata _mouths) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _mouths.length; i++) {
            _addMouth(_mouths[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox background names.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyBackgroundNames(string[] calldata _backgroundNames) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _backgroundNames.length; i++) {
            _addBackgroundName(_backgroundNames[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox body names.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyBodyNames(string[] calldata _bodyNames) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _bodyNames.length; i++) {
            _addBodyName(_bodyNames[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox accessory names.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyAccessoryNames(string[] calldata _accessoryNames) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _accessoryNames.length; i++) {
            _addAccessoryName(_accessoryNames[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox head names.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyHeadNames(string[] calldata _headNames) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _headNames.length; i++) {
            _addHeadName(_headNames[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox eyes names.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyEyesNames(string[] calldata _eyesNames) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _eyesNames.length; i++) {
            _addEyesName(_eyesNames[i]);
        }
    }

    /**
     * @notice Batch add ArbiBox mouth names.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyMouthNames(string[] calldata _mouthNames) external override onlyOwner whenPartsNotLocked {
        for (uint256 i = 0; i < _mouthNames.length; i++) {
            _addMouthName(_mouthNames[i]);
        }
    }

    /**
     * @notice Add a single color to a color palette.
     * @dev This function can only be called by the owner.
     */
    function addColorToPalette(uint8 _paletteIndex, string calldata _color) external override onlyOwner {
        require(palettes[_paletteIndex].length <= 255, 'Palettes can only hold 256 colors');
        _addColorToPalette(_paletteIndex, _color);
    }

    /**
     * @notice Add a ArbiBox background.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBgColor(string calldata _bgColor) external override onlyOwner whenPartsNotLocked {
        _addBgColor(_bgColor);
    }

    /**
     * @notice Add a ArbiBox background.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBackground(bytes calldata _background) external override onlyOwner whenPartsNotLocked {
        _addBackground(_background);
    }

    /**
     * @notice Add a ArbiBox body.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBody(bytes calldata _body) external override onlyOwner whenPartsNotLocked {
        _addBody(_body);
    }

    /**
     * @notice Add a ArbiBox accessory.
     * @dev This function can only be called by the owner when not locked.
     */
    function addAccessory(bytes calldata _accessory) external override onlyOwner whenPartsNotLocked {
        _addAccessory(_accessory);
    }

    /**
     * @notice Add a ArbiBox head.
     * @dev This function can only be called by the owner when not locked.
     */
    function addHead(bytes calldata _head) external override onlyOwner whenPartsNotLocked {
        _addHead(_head);
    }

    /**
     * @notice Add ArbiBox eyes.
     * @dev This function can only be called by the owner when not locked.
     */
    function addEyes(bytes calldata _eyes) external override onlyOwner whenPartsNotLocked {
        _addEyes(_eyes);
    }

    /**
     * @notice Add ArbiBox mouth.
     * @dev This function can only be called by the owner when not locked.
     */
    function addMouth(bytes calldata _mouth) external override onlyOwner whenPartsNotLocked {
        _addMouth(_mouth);
    }

    /**
     * @notice Add a ArbiBox background Name.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBackgroundName(string calldata _backgroundName) external override onlyOwner whenPartsNotLocked {
        _addBackgroundName(_backgroundName);
    }

    /**
     * @notice Add a ArbiBox body Name.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBodyName(string calldata _bodyName) external override onlyOwner whenPartsNotLocked {
        _addBodyName(_bodyName);
    }

    /**
     * @notice Add a ArbiBox accessory Name.
     * @dev This function can only be called by the owner when not locked.
     */
    function addAccessoryName(string calldata _accessoryName) external override onlyOwner whenPartsNotLocked {
        _addAccessoryName(_accessoryName);
    }

    /**
     * @notice Add a ArbiBox head Name.
     * @dev This function can only be called by the owner when not locked.
     */
    function addHeadName(string calldata _headName) external override onlyOwner whenPartsNotLocked {
        _addHeadName(_headName);
    }

    /**
     * @notice Add ArbiBox eyes Name.
     * @dev This function can only be called by the owner when not locked.
     */
    function addEyesName(string calldata _eyesName) external override onlyOwner whenPartsNotLocked {
        _addEyesName(_eyesName);
    }

    /**
     * @notice Add ArbiBox mouth Name.
     * @dev This function can only be called by the owner when not locked.
     */
    function addMouthName(string calldata _mouthName) external override onlyOwner whenPartsNotLocked {
        _addMouthName(_mouthName);
    }

    /**
     * @notice Lock all ArbiBox parts.
     * @dev This cannot be reversed and can only be called by the owner when not locked.
     */
    function lockParts() external override onlyOwner whenPartsNotLocked {
        arePartsLocked = true;

        emit PartsLocked();
    }

    /**
     * @notice Toggle a boolean value which determines if `tokenURI` returns a data URI
     * or an HTTP URL.
     * @dev This can only be called by the owner.
     */
    function toggleDataURIEnabled() external override onlyOwner {
        bool enabled = !isDataURIEnabled;

        isDataURIEnabled = enabled;
        emit DataURIToggled(enabled);
    }

    /**
     * @notice Set the base URI for all token IDs. It is automatically
     * added as a prefix to the value returned in {tokenURI}, or to the
     * token ID if {tokenURI} is empty.
     * @dev This can only be called by the owner.
     */
    function setBaseURI(string calldata _baseURI) external override onlyOwner {
        baseURI = _baseURI;

        emit BaseURIUpdated(_baseURI);
    }

    /**
     * @notice Given a token ID and seed, construct a token URI for an official ArbiBox Treasury arbibox.
     * @dev The returned value may be a base64 encoded data URI or an API URL.
     */
    function tokenURI(uint256 tokenId, IArbiBoxSeeder.Seed memory seed) external view override returns (string memory) {
        if (isDataURIEnabled) {
            return dataURI(tokenId, seed);
        }
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    /**
     * @notice Given a token ID and seed, construct a base64 encoded data URI for an official ArbiBox Treasury arbibox.
     */
    function dataURI(uint256 tokenId, IArbiBoxSeeder.Seed memory seed) public view override returns (string memory) {
        string memory arbiboxId = tokenId.toString();
        string memory name = string(abi.encodePacked('ArbiBox ', arbiboxId));
        string memory description = string(abi.encodePacked('ArbiBox ', arbiboxId, ' is a member of the ArbiBox Treasury'));

        return genericDataURI(name, description, seed);
    }

    /**
     * @notice Given a name, description, and seed, construct a base64 encoded data URI.
     */
    function genericDataURI(
        string memory name,
        string memory description,
        IArbiBoxSeeder.Seed memory seed
    ) public view override returns (string memory) {
        NFTDescriptor.TokenURIParams memory params = NFTDescriptor.TokenURIParams({
            name: name,
            description: description,
            parts: _getPartsForSeed(seed),
            background: bgColors[seed.background],
            names: _getAttributesForSeed(seed)
        });
        return NFTDescriptor.constructTokenURI(params, palettes);
    }

    /**
     * @notice Given a seed, construct a base64 encoded SVG image.
     */
    function generateSVGImage(IArbiBoxSeeder.Seed memory seed) external view override returns (string memory) {
        MultiPartRLEToSVG.SVGParams memory params = MultiPartRLEToSVG.SVGParams({
            parts: _getPartsForSeed(seed),
            background: bgColors[seed.background]
        });
        return NFTDescriptor.generateSVGImage(params, palettes);
    }

    /**
     * @notice Add a single color to a color palette.
     */
    function _addColorToPalette(uint8 _paletteIndex, string calldata _color) internal {
        palettes[_paletteIndex].push(_color);
    }

    /**
     * @notice Add a ArbiBox background.
     */
    function _addBgColor(string calldata _bgColor) internal {
        bgColors.push(_bgColor);
    }

    /**
     * @notice Add a ArbiBox background.
     */
    function _addBackground(bytes calldata _background) internal {
        backgrounds.push(_background);
    }

    /**
     * @notice Add a ArbiBox body.
     */
    function _addBody(bytes calldata _body) internal {
        bodies.push(_body);
    }

    /**
     * @notice Add a ArbiBox accessory.
     */
    function _addAccessory(bytes calldata _accessory) internal {
        accessories.push(_accessory);
    }

    /**
     * @notice Add a ArbiBox head.
     */
    function _addHead(bytes calldata _head) internal {
        heads.push(_head);
    }

    /**
     * @notice Add ArbiBox eyes.
     */
    function _addEyes(bytes calldata _eyes) internal {
        eyes.push(_eyes);
    }

    /**
     * @notice Add ArbiBox mouth.
     */
    function _addMouth(bytes calldata _mouth) internal {
        mouths.push(_mouth);
    }

    /**
     * @notice Add a ArbiBox background.
     */
    function _addBackgroundName(string calldata _backgroundName) internal {
        backgroundNames.push(_backgroundName);
    }

    /**
     * @notice Add a ArbiBox body.
     */
    function _addBodyName(string calldata _bodyName) internal {
        bodyNames.push(_bodyName);
    }

    /**
     * @notice Add a ArbiBox accessory.
     */
    function _addAccessoryName(string calldata _accessoryName) internal {
        accessoryNames.push(_accessoryName);
    }

    /**
     * @notice Add a ArbiBox head.
     */
    function _addHeadName(string calldata _headName) internal {
        headNames.push(_headName);
    }

    /**
     * @notice Add ArbiBox eyes.
     */
    function _addEyesName(string calldata _eyesName) internal {
        eyesNames.push(_eyesName);
    }

    /**
     * @notice Add ArbiBox mouth.
     */
    function _addMouthName(string calldata _mouthName) internal {
        mouthNames.push(_mouthName);
    }

    /**
     * @notice Get all ArbiBox parts for the passed `seed`.
     */
    function _getPartsForSeed(IArbiBoxSeeder.Seed memory seed) internal view returns (bytes[] memory) {
        bytes[] memory _parts = new bytes[](6);
        _parts[0] = backgrounds[seed.background];
        _parts[1] = bodies[seed.body];
        _parts[2] = heads[seed.head];
        _parts[3] = accessories[seed.accessory];
        _parts[4] = eyes[seed.eyes];
        _parts[5] = mouths[seed.mouth];
        return _parts;
    }

    /**
     * @notice Get all ArbiBox attributes for the passed `seed`.
     */
    function _getAttributesForSeed(IArbiBoxSeeder.Seed memory seed) internal view returns (string[] memory) {
        string[] memory _attributes = new string[](6);
        _attributes[0] = backgroundNames[seed.background];
        _attributes[1] = bodyNames[seed.body];
        _attributes[2] = headNames[seed.head];
        _attributes[3] = accessoryNames[seed.accessory];
        _attributes[4] = eyesNames[seed.eyes];
        _attributes[5] = mouthNames[seed.mouth];
        return _attributes;
    }
}
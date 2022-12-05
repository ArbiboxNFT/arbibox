"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const ethers_1 = require("ethers");
const config_1 = require("hardhat/config");
(0, config_1.task)('create-proposal', 'Create a governance proposal')
    .addOptionalParam('arbinautsDaoProxy', 'The `ArbinautsDAOProxy` contract address', '0x610178dA211FEF7D417bC0e6FeD39F05609AD788', config_1.types.string)
    .setAction(({ arbinautsDaoProxy }, { ethers }) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    const arbinautsDaoFactory = yield ethers.getContractFactory('ArbinautsDAOLogicV1');
    const arbinautsDao = arbinautsDaoFactory.attach(arbinautsDaoProxy);
    const [deployer] = yield ethers.getSigners();
    const oneETH = ethers_1.utils.parseEther('1');
    const receipt = yield (yield arbinautsDao.propose([deployer.address], [oneETH], [''], ['0x'], '# Test Proposal\n## This is a **test**.')).wait();
    if (!((_a = receipt.events) === null || _a === void 0 ? void 0 : _a.length)) {
        throw new Error('Failed to create proposal');
    }
    console.log('Proposal created');
}));

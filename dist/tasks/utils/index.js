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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.printContractsTable = exports.dataToDescriptorInput = exports.printEstimatedCost = exports.getDeploymentConfirmationWithPrompt = exports.getGasPriceWithPrompt = void 0;
const ethers_1 = require("ethers");
const prompt_1 = __importDefault(require("prompt"));
const zlib_1 = require("zlib");
prompt_1.default.colors = false;
prompt_1.default.message = '> ';
prompt_1.default.delimiter = '';
function getGasPriceWithPrompt(ethers) {
    return __awaiter(this, void 0, void 0, function* () {
        const gasPrice = yield ethers.provider.getGasPrice();
        const gasInGwei = Math.round(Number(ethers.utils.formatUnits(gasPrice, 'gwei')));
        prompt_1.default.start();
        let result = yield prompt_1.default.get([
            {
                properties: {
                    gasPrice: {
                        type: 'integer',
                        required: true,
                        description: 'Enter a gas price (gwei)',
                        default: gasInGwei,
                    },
                },
            },
        ]);
        return ethers.utils.parseUnits(result.gasPrice.toString(), 'gwei');
    });
}
exports.getGasPriceWithPrompt = getGasPriceWithPrompt;
function getDeploymentConfirmationWithPrompt() {
    return __awaiter(this, void 0, void 0, function* () {
        const result = yield prompt_1.default.get([
            {
                properties: {
                    confirm: {
                        type: 'string',
                        description: 'Type "DEPLOY" to confirm:',
                    },
                },
            },
        ]);
        return result.confirm == 'DEPLOY';
    });
}
exports.getDeploymentConfirmationWithPrompt = getDeploymentConfirmationWithPrompt;
function printEstimatedCost(factory, gasPrice) {
    return __awaiter(this, void 0, void 0, function* () {
        const deploymentGas = yield factory.signer.estimateGas(factory.getDeployTransaction({ gasPrice }));
        const deploymentCost = deploymentGas.mul(gasPrice);
        console.log(`Estimated cost to deploy ArbinautsDAOLogicV2: ${ethers_1.utils.formatUnits(deploymentCost, 'ether')} ETH`);
    });
}
exports.printEstimatedCost = printEstimatedCost;
function dataToDescriptorInput(data) {
    const abiEncoded = ethers_1.ethers.utils.defaultAbiCoder.encode(['bytes[]'], [data]);
    const encodedCompressed = `0x${(0, zlib_1.deflateRawSync)(Buffer.from(abiEncoded.substring(2), 'hex')).toString('hex')}`;
    const originalLength = abiEncoded.substring(2).length / 2;
    const itemCount = data.length;
    return {
        encodedCompressed,
        originalLength,
        itemCount,
    };
}
exports.dataToDescriptorInput = dataToDescriptorInput;
function printContractsTable(contracts) {
    console.table(Object.values(contracts).reduce((acc, contract) => {
        var _a;
        acc[contract.name] = {
            Address: contract.address,
        };
        if ((_a = contract.instance) === null || _a === void 0 ? void 0 : _a.deployTransaction) {
            acc[contract.name]['Deployment Hash'] = contract.instance.deployTransaction.hash;
        }
        return acc;
    }, {}));
}
exports.printContractsTable = printContractsTable;

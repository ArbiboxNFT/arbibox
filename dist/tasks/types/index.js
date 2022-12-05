"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChainId = void 0;
var ChainId;
(function (ChainId) {
    ChainId[ChainId["Mainnet"] = 1] = "Mainnet";
    ChainId[ChainId["Ropsten"] = 3] = "Ropsten";
    ChainId[ChainId["Rinkeby"] = 4] = "Rinkeby";
    ChainId[ChainId["Goerli"] = 5] = "Goerli";
    ChainId[ChainId["Kovan"] = 42] = "Kovan";
    ChainId[ChainId["Arbitrum"] = 42161] = "Arbitrum";
    ChainId[ChainId["ArbitrumRinkeby"] = 421611] = "ArbitrumRinkeby";
    ChainId[ChainId["ArbitrumGoerli"] = 421613] = "ArbitrumGoerli";
})(ChainId = exports.ChainId || (exports.ChainId = {}));

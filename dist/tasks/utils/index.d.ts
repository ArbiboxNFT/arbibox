import { HardhatEthersHelpers } from '@nomiclabs/hardhat-ethers/types';
import type { BigNumber, ContractFactory, ethers as ethersType } from 'ethers';
import { ContractName, DeployedContract } from '../types';
export declare function getGasPriceWithPrompt(ethers: typeof ethersType & HardhatEthersHelpers): Promise<BigNumber>;
export declare function getDeploymentConfirmationWithPrompt(): Promise<boolean>;
export declare function printEstimatedCost(factory: ContractFactory, gasPrice: BigNumber): Promise<void>;
export declare function dataToDescriptorInput(data: string[]): {
    encodedCompressed: string;
    originalLength: number;
    itemCount: number;
};
export declare function printContractsTable(contracts: Record<ContractName, DeployedContract>): void;

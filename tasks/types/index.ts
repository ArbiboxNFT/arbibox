import { Contract } from 'ethers';

export enum ChainId {
  Mainnet = 1,
  Ropsten = 3,
  Rinkeby = 4,
  Goerli = 5,
  Kovan = 42,
  Arbitrum = 42161,
  ArbitrumRinkeby = 421611,
  ArbitrumGoerli = 421613,
}

// prettier-ignore
export type DescriptorV1ContractNames = 'NFTDescriptor' | 'ArbinautsDescriptor';
// prettier-ignore
export type DescriptorV2ContractNames = 'NFTDescriptorV2' | 'ArbinautsDescriptorV2' | 'SVGRenderer' | 'ArbinautsArt' | 'Inflator';
// prettier-ignore
export type ContractName = DescriptorV2ContractNames | 'ArbinautsSeeder' | 'ArbinautsToken' | 'ArbinautsAuctionHouse' | 'ArbinautsAuctionHouseProxyAdmin' | 'ArbinautsAuctionHouseProxy' | 'ArbinautsDAOExecutor' | 'ArbinautsDAOLogicV1' | 'ArbinautsDAOProxy';
// prettier-ignore
export type ContractNameDescriptorV1 = DescriptorV1ContractNames | 'ArbinautsSeeder' | 'ArbinautsToken' | 'ArbinautsAuctionHouse' | 'ArbinautsAuctionHouseProxyAdmin' | 'ArbinautsAuctionHouseProxy' | 'ArbinautsDAOExecutor' | 'ArbinautsDAOLogicV1' | 'ArbinautsDAOProxy';
// prettier-ignore
export type ContractNamesDAOV2 = Exclude<ContractName, 'ArbinautsDAOLogicV1' | 'ArbinautsDAOProxy'> | 'ArbinautsDAOLogicV2' | 'ArbinautsDAOProxyV2';

export interface ContractDeployment {
  args?: (string | number | (() => string))[];
  libraries?: () => Record<string, string>;
  waitForConfirmation?: boolean;
  validateDeployment?: () => void;
}

export interface DeployedContract {
  name: string;
  address: string;
  instance: Contract;
  constructorArguments: (string | number)[];
  libraries: Record<string, string>;
}

export interface ContractRow {
  Address: string;
  'Deployment Hash'?: string;
}

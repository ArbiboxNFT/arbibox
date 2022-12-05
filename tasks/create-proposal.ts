import { utils } from 'ethers';
import { task, types } from 'hardhat/config';

task('create-proposal', 'Create a governance proposal')
  .addOptionalParam(
    'arbinautsDaoProxy',
    'The `ArbinautsDAOProxy` contract address',
    '0x610178dA211FEF7D417bC0e6FeD39F05609AD788',
    types.string,
  )
  .setAction(async ({ arbinautsDaoProxy }, { ethers }) => {
    const arbinautsDaoFactory = await ethers.getContractFactory('ArbinautsDAOLogicV1');
    const arbinautsDao = arbinautsDaoFactory.attach(arbinautsDaoProxy);

    const [deployer] = await ethers.getSigners();
    const oneETH = utils.parseEther('1');

    const receipt = await (
      await arbinautsDao.propose(
        [deployer.address],
        [oneETH],
        [''],
        ['0x'],
        '# Test Proposal\n## This is a **test**.',
      )
    ).wait();
    if (!receipt.events?.length) {
      throw new Error('Failed to create proposal');
    }
    console.log('Proposal created');
  });

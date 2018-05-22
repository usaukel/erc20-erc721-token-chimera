
import { assertRevert, assertError } from './helpers/assertRevert';
const BigNumber = web3.BigNumber;

const Chimera = artifacts.require('Chimera');
const Exchange = artifacts.require('Exchange');

function checkEventEmitted(log, eventName) {
  log.event.should.be.eq(eventName);
}

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Chimera ERC20/ERC721', accounts => {
  const [creator, owner, user1, user2, user3] = accounts;

  let chimera = null;

  const sentByCreator = { from: creator };
  const sentByOwner = { from: owner };
  const sentByUser1 = { from: user1 };
  const sentByUser2 = { from: user2 };
  const sentByUser3 = { from: user3 };

  const tokenName = 'Picasso token';
  const tokenSymbol = 'PIC';
  const tokenDecimals = 0;
  const tokenTotalSupply = 1000;

  const firstMediaUri = 'http://swarm.blockscan.com/bzz:/43ec1080b3d36aea6653b888de1ff16e8884d3ea95f22ffee68a394e114e571b';
  const secondMediaUri = 'http://swarm.blockscan.com/bzz:/b4a45796dbb19eea0c4dc0c27dfb6521d550c1433640eac6791569ef9cd28f9a';

  // Create
  const creationParams = {
    gas: 9e8,
    gasPrice: 21e9,
    from: creator
  };

  beforeEach(async () => {
    chimera = await Chimera.new(tokenName, tokenSymbol, tokenDecimals, tokenTotalSupply, creationParams);
    await chimera.addAsset(1, 'Les Demoiselles d’Avignon', firstMediaUri, sentByCreator);
  })

  describe('Token variables', () => {
    it('Name is correct', async () => {
      const name = await chimera.name();
      name.should.be.eq(tokenName);
    });
    it('Symbol is correct', async () => {
      const symbol = await chimera.symbol();
      symbol.should.be.eq(tokenSymbol);
    });
    it('Decimals is correct', async () => {
      const decimals = await chimera.decimals();
      decimals.should.be.bignumber.equal(tokenDecimals);
    });
    it('Total supply is correct', async () => {
      const totalSupply = await chimera.totalSupply();
      totalSupply.should.be.bignumber.equal(tokenTotalSupply);
    });
  });

  describe('Non-fungible assets', async () => {
    it('Amount of non-fungible assets should be 1', async () => {
      const assetAmount = await chimera.numAssets();
      assetAmount.should.be.bignumber.equal(1);
    });
    it('Add mediaUri to existing asset', async () => {
      const { logs } = await chimera.addMediaUri(1, firstMediaUri, sentByCreator);
      const log = logs[0];
      log.event.should.be.eq('AddMediaUri');
    });
    it('Add mediaUri to NON-existing asset fails', async () => {
      await assertRevert(chimera.addMediaUri(2, secondMediaUri, sentByCreator));
    });
  });

  describe('Transfer and allowance', async () => {
    it(`Balance of creator should be ${tokenTotalSupply}`, async () => {
      const creatorBalance = await chimera.balanceOf(creator);
      creatorBalance.should.be.bignumber.equal(tokenTotalSupply);
    });
    it('Transfer to user1', async () => {
      await chimera.transfer(user1, 100, sentByCreator);
      const userBalance = await chimera.balanceOf(user1);
      userBalance.should.be.bignumber.equal(100);
    });
    it('Give allowance to user2 as user1', async () => {
      await chimera.transfer(user1, 100, sentByCreator);
      await chimera.approve(user2, 100, sentByUser1);
      const allowance = await chimera.allowance(user1, user2);
      allowance.should.be.bignumber.equal(100);
    });
    it('TransferFrom user1 to user3 as allowed user2', async () => {
      await chimera.transfer(user1, 100, sentByCreator);
      await chimera.approve(user2, 100, sentByUser1);
      const { logs } = await chimera.transferFrom(user1, user3, 100, sentByUser2);
      const log = logs[0];
      log.event.should.be.eq('Transfer');
      log.args._from.should.be.equal(user1);
      log.args._to.should.be.equal(user3);
      const userBalance = await chimera.balanceOf(user3);
      userBalance.should.be.bignumber.equal(100);
    })
  });
});

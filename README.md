THE PROJECT 

This solution implements a Rewards Booster vault using the Foundry Framework.

## The Deposit Contract

The Deposit Contract accepts deposits of several ERC-20 Tokens, namely [Uniswap LP tokens](https://github.com/Uniswap/v2-core/blob/master/contracts/UniswapV2ERC20.sol). 
There is a pool for each token that the Deposit Contract receives and each pool should be considered individually, since all the logic that follows is valid for a single pool. 
The Owner is responsible to whitelist tokens. 
It is also possible for the owner to freeze tokens from being whitelisted, which will disable new deposits and will stop the accrual of new rewards.

### Deposits

By deposit tokens, the user gets rewards in the form of [Tokens] for the deposited LP tokens. 
The rewards are distributed proportionally amongst the depositors based on their deposits and start accruing as soon as the deposit occurs. 
There is a base rate of tokens that is emitted per block and this value can be changed by the owner. 
When depositing tokens, the protocol takes a fee and sends it to a recipient address paid in the token being deposited. 
This fee is a percentage of the deposit and it can be changed by the owner at any time (there is only 1 value for all the pools). 

Users can claim their pending rewards at any time and as many times as they want. 
In each block the number of tokens emitted should be the multiplication of the base rate and the reward multiplier for that period.

Period				Reward Multiplier
0 - 100 blocks		100x
101- 200 blocks		50x
201 - 300 blocks	25x
301 - 400 blocks	10x
Not Defined			1x

### Withdraws

When withdrawing tokens, the depositors might have to pay a fee depending on the amount of time the tokens have been locked for. 
The fee depends on how long the tokens were locked for, and this value can be set by the owner of the contract. 
Both the period and the fee is customizable by the owner. The table below is just a possible example, there are no restrictions regarding the periods or the fees.

Period				Fee
0-0 blocks			15%
0-100 blocks		10%
100-1000 blocks		5%
1000-10000 blocks	2.5%
Not Defined			0%

## The Booster Packs

The Booster Packs are NFTs that can be burned in order to increase the amount of rewards a user gets when deposit tokens. 
The owner can add or remove addresses to be eligible for burning and minting Booster Packs.

Each set of Booster Packs will have 3 attributes: a duration, an expiration timestamp (the booster is no longer eligible to be used) and a multiplier of rewards,  all set by the owner once they are created. 
There can exist several different Booster of the same type, the same way the [Bored Ape Chemistry Club](https://opensea.io/collection/bored-ape-chemistry-club) collection has several seerums of the same type.

The Booster Pack increases rewards for a specific user that burned the Booster Pack for a specific pool. 
You can only have 1 activated Booster Pack per pool per user at the same time. 
The rewards are applied to all the deposited made by the user to that pool for the entire duration of the Booster. 
The extra rewards do not count for the distribution of tokens by depositors, since they are extra tokens to be emitted and sent to the depositor.

## The Token

The Token should be an ERC-20 implementation can only be minted by the [Deposit Contract].
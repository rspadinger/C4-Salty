# Salty.IO Protocol Analysis

# Table of Contents
- [1 Overview of the Salty.IO Protocol](#1-overview-of-the-salty-io-protocol)
    - [1.1 Key Features of the DEX](#1-1-key-features-of-the-dex)
    - [1.2 The Core Modules and Main Actors of the Salty.IO Protocol](#1-2-the-core-modules-and-main-actors-of-the-salty-io-protocol)

- [2 Analysis of the Protocol Components and Smart Contracts](#2-analysis-of-the-protocol-components-and-smart-contracts)
    - [2.1 The DAO](#2-1-the-dao)
    - [2.1.1 DAO.sol](#2-1-1-dao-sol)
    - [2.1.2 Proposals.sol](#2-1-2-proposals-sol)
    - [2.1.3 DAOConfig.sol](#2-1-3-daoconfig-sol)
    - [2.1.4 Parameters.sol](#2-1-4-parameters-sol)
    - [2.1.5 Principal Actors of the DAO](#2-1-5-principal-actors-of-the-dao)

<a id="1-overview-of-the-salty-io-protocol"></a>
# 1 Overview of the Salty.IO Protocol

Salty.IO is a decentralized exchange (DEX) that provides feeless swaps. The protocol is entirely governed by a DAO and provides a native stablecoin (USDS) that is backed by an overcollateralized pool of WBTC/WETH tokens. 

**There are a few key features that are particularly interesting about this exchange:**

**Feeless swaps and arbitrage profits:**

In order to allow feeless swaps, the protocol needs a sustainable way to remunerate liquidity providers without relying entirely on the SALT protocol token. Salty.IO provides a mechanism they call "Automatic Atomic Arbitrage" or AAA. This generates arbitrage profits from in-transaction swaps on all liquidity pools that belong to the protocol.

By performing those arbitrage trades within the transaction of the actual user swap, the protocol does not need to compete with highly sophisticated arbitrage bots. Furthermore, those trades are highly optimized in terms of gas fees and profits.

To achieve the maximum profit, the protocol uses an iterative bisection search to evaluate the most profitable amounts for the arbitrage trades.

Those profits are then distributed to SALT (governance/protocol token) stakers, to the protocol owned liquidity pools that help to stabilize the peg of the USDS stablecoin and the remaining part goes to use who participate in the upkeep of the exchange.


**Decentralization through DAO governance:**

It is also refreshing sign to see that the team strives to achieve a maximum amount of decentralization by handing over the governance of the protocol to a DAO.

Users can stake protocol/governance SALT tokens in order to participate in the governance process and to be eligible for SALT staking rewards.


**Overcollateralized Stablecoin USDS:**

Not many DEXes provide their own stablecoin. The peg is assured by using various measures, like having a high initial overcollateralization rate in the form of WBTC/WETH tokens for users who want to borrow USDS. Also, the protocol owned liquidity pools can provide additional USDS tokens to be burned in the case of under collateralized liquidations of USDS borrowers.


**Protection against oracle price failure:**

It is also great to see that the protocol does not rely only on one single price feed, but uses three different feeds to provide most accurate prices for BTC and ETH and to protect the protocol against a fatal failure from one of those price feeds.

<a id="1-1-key-features-of-the-dex"></a>
## 1.1 Key Features of the DEX

**Here is a very short summary of the main features of the DEX. A more in-depth explanation of those features is provided in the sections below:** 

* Feeless swaps on all protocol pools
* Automatic Atomic Arbitrage to provide those feeless swaps, to reward SALT stakers and to inject liquidity into the protocol owned pools
* USDS native stablecoin
* Users can borrow USDS by providing WBTC/WETH collateral
* The protocol is entirely governed by a DAO to achieve maximum decentralization.
* SALT rewards for liquidity providers and SALT stakers
* Protocol owned liquidity pools (SALT/USDS and USDS/DAI) to protect the USDS peg in the case of potential losses from undercollateralized liquidations
* Three different price feeds for BTC and ETH from Chainlink, Uniswap v3 and Salty.IO pools to obtain accurate prices
* Airdrop at protocol launch


<a id="1-2-the-core-modules-and-main-actors-of-the-salty-io-protocol"></a>
## 1.2 The Core Modules and Main Actors of the Salty.IO Protocol

The Salty.IO protocol consists of 7 key modules or components that provide the various features of the DEX. Those modules correspond more or less with the main folders in the code repository. There are just a few minor modifications that are detailed in the sections below that proved detailed information about each component and their associated contracts.

**Here is a list of all protocol modules:**

* DAO
* Pools
* Price Feeds
* Stablecoin
* Staking
* Rewards
* Exchange & Launch


**And, those are the different exchange actors. Some of them are exchange contracts, others are exchange users (externally owned accounts):**

**Contracts:**

* DAO
* Upkeep contract
* Liquidizer contract
* BootstrapBallot contract
* CollateralAndLiquidity contract
* InitialDistribution contract
* Airdrop contract


**Users:**

* SALT Staker
* Swap User
* USDS Borrower
* Liquidity Provider
* Airdrop Participant
* Protocol Team


**The image below provides a high-level overview of all the the protocol components and the actors involved:**

![Architecture](https://github.com/rspadinger/C4-Salty/blob/master/code/images/Architecture.png?raw=true)
 

<a id="2-analysis-of-the-protocol-components-and-smart-contracts"></a>
# 2 Analysis of the Protocol Components and Smart Contracts  

<a id="2-1-the-dao"></a>
## 2.1 The DAO 

**Source:** https://github.com/code-423n4/2024-01-salty/tree/main/src/dao

To achieve a maximum amount of decentralization a DAO has been implemented, which has complete ownership and full control over the Salty.IO protocol.

DAO members (stakers of SALT tokens) can propose various changes related to the Salty.IO protocol and vote on those proposed changes. Proposals include the change of various protocol parameters, modifications to the tokens whitelist, sending SALT tokens, updating the Salty.IO website url, calling other contracts... and more. The DAO contract handles typical DAO related functionalty, such as the creation of proposals, vote tracking and the execution of proposals if the configured requirements (such as the quorum) are met.  

**The DAO consists of the following smart contracts:**

* DAO
* Proposals
* DAOConfig
* Parameters

The image below provides a high-level overview of the DAO with all smart contracts involved, the core features provided by each individual contract and all involved actors. A detailed description of each smart contract is provided in the following sections of the report.      


![DAO](https://github.com/rspadinger/C4-Salty/blob/master/code/images/DAO.png?raw=true)


<a id="2-1-1-dao-sol"></a>
### 2.1.1 DAO.sol

**Source:** https://github.com/code-423n4/2024-01-salty/blob/main/src/dao/DAO.sol

This is the main contract of the protocol DAO and it allows to finalize ballots, withdraw arbitrage profits to the Upkeep contract, add liquidity to the protocol owned liquidity (POL), process team rewards and burn SALT tokens... Those features are explained in more detail in the "Functions" section below.

#### Imports:

OpenZeppelin ReentrancyGuard and contracts/interfaces from all other protocol components expect the Launch component.

#### State Variables: 

References to various key components of the protocol, such as: liquidity pools, price agregator, rewards emitter, liquidizer, configurations for the exchange, pools, staking, rewards and the DAO, as well as the tokens required for th eprotocol owned liquidity (PO): SALT, DAI and USDS. All of those variables are immutable and internal and they are set in the constructor.

On top of those variables, we also have the IPFS URL of the protocol website and a mapping for all excluded countries both are public.

**Immutable:** pools, proposals, exchangeConfig, poolsConfig, stakingConfig, rewardsConfig, stableConfig, daoConfig, priceAggregator, liquidityRewardsEmitter, collateralAndLiquidity, liquidizer, salt, usds, dai

**Others:** websiteURL, excludedCountries

#### Functions:

**The external state-changing functions allow to:**

* finalize specific ballots that are in a finalizable state  
* withdraw WETH arbitrage profits from the pools to the Upkeep contract 
* create protocol owned liquidity (POL) with the specified tokens and amounts for the SALT/USDS or USDS/DAI pools. This can only be called by the Upkeep contract. Also, a zapping algorithm is used to use all specified tokens  
* process team rewards from the POL and burn the remaining SALT tokens. Again, this can only be called by the Upkeep contract 
* withdraw a specified amount of tokens from the POL, convert them into USDS and burn them in case the recovered collateral amount from liquidations is not sufficient to burn the required amount of USDS. This function can only be called by the Liquidizer contract  


**Here is a list of the corresponding functions:**

* finalizeBallot(uint256 ballotID)
* withdrawArbitrageProfits(IERC20 weth)
* formPOL(IERC20 tokenA, IERC20 tokenB, uint256 amountA, uint256 amountB)
* processRewardsFromPOL()
* withdrawPOL(IERC20 tokenA, IERC20 tokenB, uint256 percentToLiquidate)


**There is 1 external view function that allows to verify if a specific country is excluded from the whitelist:**

* countryIsExcluded(string country) returns (bool)


All core functions emit corresponding events.


<a id="2-1-2-proposals-sol"></a>
### 2.1.2 Proposals.sol

**Source:** https://github.com/code-423n4/2024-01-salty/blob/main/src/dao/Proposals.sol

The Proposals contract allows all SALT stakers to create differnt types of proposals and to vote for those proposals. DAO members can make proposals to change specific protocol parameters, to add or remove tokens from a whitelist, to send SALT to a specified address, to update the price fee contracts, to call external contracts... and more.


#### Imports:

Various OpenZeppelin contracts as well as interfaces for pool, staking and configuration management.


#### State Variables: 

State is stored for exchange, DAO and pool configuration parameters and for various ballot related data, such as: ballots and open ballots, the next ballot Id, votes for a specific ballot, last user vote for a specific ballot, if a specific user has an active proposal, the last user vote for a specific ballot... and others.

Most of the ballot related variables are mappings, such as: mapping(address=>bool) private _userHasActiveProposal; which verifies if a specific user has an active proposal.

The names of the different state variables are self-explanatory, so no further detail is provided here:

**Public immutable:** staking, exchangeConfig, poolsConfig, daoConfig, salt

**Public ballot related:** openBallotsByName, ballots, nextBallotID, 

**Private ballot related:** _allOpenBallots, _openBallotsForTokenWhitelisting, _votesCastForBallot, _lastUserVoteForBallot, _userHasActiveProposal, _usersThatProposedBallots, firstPossibleProposalTimestamp


#### Functions:  

The external state changing functions allow to vote for a specific proposal and to make different types of proposals, such as proposals for country inclusion and exclusion, proposal to send SALT tokens, to call a specific contract, to change DAO or protocol related parameters... and more. The DAO can also finalize a specific ballot.

The names of the different functions are self-explanatory, so no further detail is provided here.

**External state changing functions:**

* castVote(uint256 ballotID, Vote vote )
* createConfirmationProposal(string ballotName, BallotType ballotType, address address1, string string1, string description) 
* markBallotAsFinalized(uint256 ballotID)	
* proposeParameterBallot(uint256 parameterType, string description)
* proposeTokenWhitelisting(IERC20 token, string tokenIconURL, string description)
* proposeTokenUnwhitelisting(IERC20 token, string tokenIconURL, string description) 
* proposeSendSALT(address wallet, uint256 amount, string description) 
* proposeCallContract(address contractAddress, uint256 number, string description) 
* proposeCountryInclusion(string country, string description)
* proposeCountryExclusion(string country, string description)
* proposeSetContractAddress(string contractName, address newAddress, string description)
* proposeWebsiteUpdate(string newWebsiteURL, string description )
   

**External view functions:**                                                 

* ballotForID(uint256 ballotID) returns (Ballot)
* lastUserVoteForBallot(uint256 ballotID, address user) returns (UserVote)
* votesCastForBallot(uint256 ballotID, Vote vote) returns (uint256)
* requiredQuorumForBallotType(BallotType ballotType) public view returns (uint256 requiredQuorum)
* totalVotesCastForBallot(uint256 ballotID) public view returns (uint256)
* ballotIsApproved(uint256 ballotID) returns (bool)
* winningParameterVote(uint256 ballotID) returns (Vote)
* canFinalizeBallot(uint256 ballotID) returns (bool)
* openBallots() returns (uint256[] memory)
* openBallotsForTokenWhitelisting() returns (uint256[])
* tokenWhitelistingBallotWithTheMostVotes() returns (uint256)
* userHasActiveProposal(address user) returns (bool)
 

**The following events are emitted when a new proposal is created, a ballot is finalized or a vote is cast:**  

* ProposalCreated;
* BallotFinalized;
* VoteCast;


<a id="2-1-3-daoconfig-sol"></a>
### 2.1.3 DAOConfig.sol

**Source:** https://github.com/code-423n4/2024-01-salty/blob/main/src/dao/DAOConfig.sol

This contract allows to configure various DAO specific parameters, such as: initial bootstraping rewards for the launch of the protocol, the reward in % for the caller of the upkeep, the duration of a ballot, the percentage of POL rewards that are burned... and more.


#### Imports:

The ownable contract from OpenZeppelin and the interface for the DAOConfig.


#### State Variables: 

All state variables are public and they are initialized with default values for various DAO specific configurations.

**The names of the different state variables are self-explanatory, so no further detail is provided here:**
 
* bootstrappingRewards = 200000 ether  
* percentPolRewardsBurned = 50
* baseBallotQuorumPercentTimes1000 = 10 * 1000 
* ballotMinimumDuration = 10 days
* requiredProposalPercentStakeTimes1000 = 500
* maxPendingTokensForWhitelisting = 5 
* arbitrageProfitsPercentPOL = 20 
* upkeepRewardPercent = 5


#### Functions:  

The functions listed below allow to change various DAO specific parameters. Their names are self-explanatory, so, no further details are provided. 

**External state changing functions:**

* changeArbitrageProfitsPercentPOL(bool increase) 
* changeBallotDuration(bool increase) 
* changeBaseBallotQuorumPercent(bool increase) 
* changeBootstrappingRewards(bool increase) 
* changeMaxPendingTokensForWhitelisting(bool increase) 
* changePercentPolRewardsBurned(bool increase) 
* changeRequiredProposalPercentStake(bool increase) 
* changeUpkeepRewardPercent(bool increase)  


**Corresponding events are emitted by all functions:**

* BootstrappingRewardsChanged
* PercentPolRewardsBurnedChanged
* BaseBallotQuorumPercentChanged
* BallotDurationChanged
* RequiredProposalPercentStakeChanged
* MaxPendingTokensForWhitelistingChanged
* ArbitrageProfitsPercentPOLChanged
* UpkeepRewardPercentChanged


<a id="2-1-4-parameters-sol"></a>
### 2.1.4 Parameters.sol

**Source:** https://github.com/code-423n4/2024-01-salty/blob/main/src/dao/Parameters.sol

This is an abstract contract from which the DAO conract inherits. It contains only one function: _executeParameterChange(), which allows to change a specic parameter, like the bootstrapping rewards, the minimum collateral ratio, the ballot duration, the staking rewards... and many others. 

The different parameters are defined in the ParameterTypes enum and there are 6 different categories:

* Pool settings: maximumWhitelistedPools, maximumInternalSwapPercentTimes1000 
* Staking configuration: minUnstakeWeeks, maxUnstakeWeeks...
* Reward settings: stakingRewardsPercent, percentRewardsSaltUSDS...
* USDS borrowing; initialCollateralRatioPercent, rewardPercentForCallingLiquidation...
* DAO settings: bootstrappingRewards, ballotDuration...
* Price aggregator: maximumPriceFeedPercentDifferenceTimes1000...


#### Functions:  

As already mentioned, there is only 1 internal function, that receives a specific parameter type and that calls the corresponding function on the specified instance (PoolsConfig, StakingConfig, RewardsConfig...) in order to increase or decrease the selected parameter.  
 
* _executeParameterChange(ParameterTypes parameterType, bool increase, IPoolsConfig poolsConfig, IStakingConfig stakingConfig, IRewardsConfig rewardsConfig, IStableConfig stableConfig, IDAOConfig daoConfig, IPriceAggregator priceAggregator )


<a id="2-1-5-principal-actors-of-the-dao"></a>
### 2.1.5 Principal Actors of the DAO

#### DAO

The DAO is the owner of the DAOConfig contract and it is also the only actor that is allowed to modify DAO specific configurations, like:

* the bootstrapping rewards
* the percentage of POL rewards to be burned
* the duration of a ballot, the base ballot quorum percentage
* the required percentage for a proposal
* the maximum pending tokens to be whitelisted
* the POL arbitrage percentage and the percentage for the upkeep rewards

The DAO is also the only actor that is allowed to perform the following action in the Proposals contract:

* creation of a confirmation proposal
* mark ballots as finalized

All other functions in the Proposals contract (that call the _possiblyCreateProposal internal function) can either be called by the DAO itself or by holders of SALT tokens.

The corresponding functions are listed above in the "2.1.3 DAOConfig.sol" and "2.1.2 Proposals.sol" sections.


#### DAO members - holders of SALT tokens

As mentioned above, holders of SALT tokens are allowed to execute all functions in the Proposals contract that call the "_possiblyCreateProposal" internal function. They are allowed to make the following propositions:

* parameter ballot
* token whitelisting and unwhitelisting
* send SALT tokens
* call a specific contract
* country inclusion and exclusion
* website update
* cast a vote 

The corresponding functions are listed above in the "2.1.2 Proposals.sol" section.


#### Upkeep

The following functions in the DAO contract can only be called by the Upkeep contract:

* withdraw arbitrage profits => withdrawArbitrageProfits(...)
* form a POL => formPOL(...)
* process rewards from a POL => processRewardsFromPOL(...)

#### Liquidizer

The following function in the DAO contract can only be called by the Liquidizer contract:

* withdraw POL => withdrawPOL(...) 



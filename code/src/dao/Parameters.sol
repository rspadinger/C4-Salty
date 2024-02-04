// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "../price_feed/interfaces/IPriceAggregator.sol";
import "../rewards/interfaces/IRewardsConfig.sol";
import "../staking/interfaces/IStakingConfig.sol";
import "../stable/interfaces/IStableConfig.sol";
import "../pools/interfaces/IPoolsConfig.sol";
import "./interfaces/IDAOConfig.sol";


abstract contract Parameters
    {
	enum ParameterTypes {

		// PoolsConfig
		maximumWhitelistedPools,
		maximumInternalSwapPercentTimes1000,

		// StakingConfig
		minUnstakeWeeks,
		maxUnstakeWeeks,
		minUnstakePercent,
		modificationCooldown,

		// RewardsConfig
    	rewardsEmitterDailyPercentTimes1000,
		emissionsWeeklyPercentTimes1000,
		stakingRewardsPercent,
		percentRewardsSaltUSDS,

		// StableConfig
		rewardPercentForCallingLiquidation,
		maxRewardValueForCallingLiquidation,
		minimumCollateralValueForBorrowing,
		initialCollateralRatioPercent,
		minimumCollateralRatioPercent,
		percentArbitrageProfitsForStablePOL,

		// DAOConfig
		bootstrappingRewards,
		percentPolRewardsBurned,
		baseBallotQuorumPercentTimes1000,
		ballotDuration,
		requiredProposalPercentStakeTimes1000,
		maxPendingTokensForWhitelisting,
		arbitrageProfitsPercentPOL,
		upkeepRewardPercent,

		// PriceAggregator
		maximumPriceFeedPercentDifferenceTimes1000,
		setPriceFeedCooldown
		}


	// If the parameter has an invalid parameterType then the call is a no-op
	function _executeParameterChange( ParameterTypes parameterType, bool increase, IPoolsConfig poolsConfig, IStakingConfig stakingConfig, IRewardsConfig rewardsConfig, IStableConfig stableConfig, IDAOConfig daoConfig, IPriceAggregator priceAggregator ) internal
		{
		// PoolsConfig
		if ( parameterType == ParameterTypes.maximumWhitelistedPools )
			poolsConfig.changeMaximumWhitelistedPools( increase );
		else if ( parameterType == ParameterTypes.maximumInternalSwapPercentTimes1000 )
			poolsConfig.changeMaximumInternalSwapPercentTimes1000( increase );

		// StakingConfig
		else if ( parameterType == ParameterTypes.minUnstakeWeeks )
			stakingConfig.changeMinUnstakeWeeks(increase);
		else if ( parameterType == ParameterTypes.maxUnstakeWeeks )
			stakingConfig.changeMaxUnstakeWeeks(increase);
		else if ( parameterType == ParameterTypes.minUnstakePercent )
			stakingConfig.changeMinUnstakePercent(increase);
		else if ( parameterType == ParameterTypes.modificationCooldown )
			stakingConfig.changeModificationCooldown(increase);

		// RewardsConfig
		else if ( parameterType == ParameterTypes.rewardsEmitterDailyPercentTimes1000 )
			rewardsConfig.changeRewardsEmitterDailyPercent(increase);
		else if ( parameterType == ParameterTypes.emissionsWeeklyPercentTimes1000 )
			rewardsConfig.changeEmissionsWeeklyPercent(increase);
		else if ( parameterType == ParameterTypes.stakingRewardsPercent )
			rewardsConfig.changeStakingRewardsPercent(increase);
		else if ( parameterType == ParameterTypes.percentRewardsSaltUSDS )
			rewardsConfig.changePercentRewardsSaltUSDS(increase);

		// StableConfig
		else if ( parameterType == ParameterTypes.rewardPercentForCallingLiquidation )
			stableConfig.changeRewardPercentForCallingLiquidation(increase);
		else if ( parameterType == ParameterTypes.maxRewardValueForCallingLiquidation )
			stableConfig.changeMaxRewardValueForCallingLiquidation(increase);
		else if ( parameterType == ParameterTypes.minimumCollateralValueForBorrowing )
			stableConfig.changeMinimumCollateralValueForBorrowing(increase);
		else if ( parameterType == ParameterTypes.initialCollateralRatioPercent )
			stableConfig.changeInitialCollateralRatioPercent(increase);
		else if ( parameterType == ParameterTypes.minimumCollateralRatioPercent )
			stableConfig.changeMinimumCollateralRatioPercent(increase);
		else if ( parameterType == ParameterTypes.percentArbitrageProfitsForStablePOL )
			stableConfig.changePercentArbitrageProfitsForStablePOL(increase);

		// DAOConfig
		else if ( parameterType == ParameterTypes.bootstrappingRewards )
			daoConfig.changeBootstrappingRewards(increase);
		else if ( parameterType == ParameterTypes.percentPolRewardsBurned )
			daoConfig.changePercentPolRewardsBurned(increase);
		else if ( parameterType == ParameterTypes.baseBallotQuorumPercentTimes1000 )
			daoConfig.changeBaseBallotQuorumPercent(increase);
		else if ( parameterType == ParameterTypes.ballotDuration )
			daoConfig.changeBallotDuration(increase);
		else if ( parameterType == ParameterTypes.requiredProposalPercentStakeTimes1000 )
			daoConfig.changeRequiredProposalPercentStake(increase);
		else if ( parameterType == ParameterTypes.maxPendingTokensForWhitelisting )
			daoConfig.changeMaxPendingTokensForWhitelisting(increase);
		else if ( parameterType == ParameterTypes.arbitrageProfitsPercentPOL )
			daoConfig.changeArbitrageProfitsPercentPOL(increase);
		else if ( parameterType == ParameterTypes.upkeepRewardPercent )
			daoConfig.changeUpkeepRewardPercent(increase);

		// PriceAggregator
		else if ( parameterType == ParameterTypes.maximumPriceFeedPercentDifferenceTimes1000 )
			priceAggregator.changeMaximumPriceFeedPercentDifferenceTimes1000(increase);
		else if ( parameterType == ParameterTypes.setPriceFeedCooldown )
			priceAggregator.changePriceFeedModificationCooldown(increase);
		}
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "../Parameters.sol";

contract TestParameters is Parameters {
    function test() public {}

    function executeParameterChange(
        ParameterTypes parameterType,
        bool increase,
        IPoolsConfig poolsConfig,
        IStakingConfig stakingConfig,
        IRewardsConfig rewardsConfig,
        IStableConfig stableConfig,
        IDAOConfig daoConfig,
        IPriceAggregator priceAggregator
    ) public {
        _executeParameterChange(
            parameterType,
            increase,
            poolsConfig,
            stakingConfig,
            rewardsConfig,
            stableConfig,
            daoConfig,
            priceAggregator
        );
    }
}

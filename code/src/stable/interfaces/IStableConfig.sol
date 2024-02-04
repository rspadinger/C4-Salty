// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

interface IStableConfig
	{
	function changeRewardPercentForCallingLiquidation(bool increase) external; // onlyOwner
	function changeMaxRewardValueForCallingLiquidation(bool increase) external; // onlyOwner
	function changeMinimumCollateralValueForBorrowing(bool increase) external; // onlyOwner
	function changeInitialCollateralRatioPercent(bool increase) external; // onlyOwner
	function changeMinimumCollateralRatioPercent(bool increase) external; // onlyOwner
	function changePercentArbitrageProfitsForStablePOL(bool increase) external; // onlyOwner

	// Views
    function rewardPercentForCallingLiquidation() external view returns (uint256);
    function maxRewardValueForCallingLiquidation() external view returns (uint256);
    function minimumCollateralValueForBorrowing() external view returns (uint256);
	function initialCollateralRatioPercent() external view returns (uint256);
	function minimumCollateralRatioPercent() external view returns (uint256);
	function percentArbitrageProfitsForStablePOL() external view returns (uint256);
	}

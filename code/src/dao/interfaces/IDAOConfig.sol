// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IDAOConfig
	{
	function changeBootstrappingRewards(bool increase) external; // onlyOwner
	function changePercentPolRewardsBurned(bool increase) external; // onlyOwner
	function changeBaseBallotQuorumPercent(bool increase) external; // onlyOwner
	function changeBallotDuration(bool increase) external; // onlyOwner
	function changeRequiredProposalPercentStake(bool increase) external; // onlyOwner
	function changeMaxPendingTokensForWhitelisting(bool increase) external; // onlyOwner
	function changeArbitrageProfitsPercentPOL(bool increase) external; // onlyOwner
	function changeUpkeepRewardPercent(bool increase) external; // onlyOwner

	// Views
    function bootstrappingRewards() external view returns (uint256);
    function percentPolRewardsBurned() external view returns (uint256);
    function baseBallotQuorumPercentTimes1000() external view returns (uint256);
    function ballotMinimumDuration() external view returns (uint256);
    function requiredProposalPercentStakeTimes1000() external view returns (uint256);
    function maxPendingTokensForWhitelisting() external view returns (uint256);
    function arbitrageProfitsPercentPOL() external view returns (uint256);
    function upkeepRewardPercent() external view returns (uint256);
	}
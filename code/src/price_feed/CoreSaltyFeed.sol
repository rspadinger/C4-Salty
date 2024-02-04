// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IExchangeConfig.sol";
import "../pools/interfaces/IPools.sol";
import "./interfaces/IPriceFeed.sol";
import "../pools/PoolUtils.sol";


// Uses the Salty.IO pools to retrieve prices for BTC and ETH.
// Prices are returned with 18 decimals.
contract CoreSaltyFeed is IPriceFeed
    {
    IPools immutable public pools;

	IERC20 immutable public wbtc;
	IERC20 immutable public weth;
	IERC20 immutable public usds;


	constructor( IPools _pools, IExchangeConfig _exchangeConfig )
		{
		pools = _pools;
		wbtc = _exchangeConfig.wbtc();
		weth = _exchangeConfig.weth();
		usds = _exchangeConfig.usds();
		}


	// Returns zero for an invalid price
	function getPriceBTC() external view returns (uint256)
		{
        (uint256 reservesWBTC, uint256 reservesUSDS) = pools.getPoolReserves(wbtc, usds);

		if ( ( reservesWBTC < PoolUtils.DUST ) || ( reservesUSDS < PoolUtils.DUST ) )
			return 0;

		// reservesWBTC has 8 decimals, keep the 18 decimals of reservesUSDS
		return ( reservesUSDS * 10**8 ) / reservesWBTC;
		}


	// Returns zero for an invalid price
	function getPriceETH() external view returns (uint256)
		{
        (uint256 reservesWETH, uint256 reservesUSDS) = pools.getPoolReserves(weth, usds);

		if ( ( reservesWETH < PoolUtils.DUST ) || ( reservesUSDS < PoolUtils.DUST ) )
			return 0;

		return ( reservesUSDS * 10**18 ) / reservesWETH;
		}
    }
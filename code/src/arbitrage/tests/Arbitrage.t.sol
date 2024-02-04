// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "../../dev/Deployment.sol";
import "./TestArbitrageSearch.sol";


contract TestArbitrage is Deployment
	{
	address public alice = address(0x1111);


	constructor()
		{
		// If $COVERAGE=yes, create an instance of the contract so that coverage testing can work
		// Otherwise, what is tested is the actual deployed contract on the blockchain (as specified in Deployment.sol)
		if ( keccak256(bytes(vm.envString("COVERAGE" ))) == keccak256(bytes("yes" )))
			initializeContracts();

		grantAccessAlice();
		grantAccessBob();
		grantAccessCharlie();
		grantAccessDeployer();
		grantAccessDefault();

		finalizeBootstrap();

		vm.prank(address(daoVestingWallet));
		salt.transfer(DEPLOYER, 1000000 ether);
		}


	function _setupTokenForTesting( IERC20 token ) public
		{
		// Whitelist the tokens with WBTC and WETH
        vm.startPrank(address(dao));
        poolsConfig.whitelistPool( pools,   token, wbtc);
        poolsConfig.whitelistPool( pools,   token, weth);
        vm.stopPrank();

		vm.startPrank(DEPLOYER);
		wbtc.transfer(alice, 1000000 *10**8);
		weth.transfer(alice, 1000000 ether);
		salt.transfer(alice, 100000 ether);
		vm.stopPrank();

		vm.startPrank(alice);
		token.approve( address(collateralAndLiquidity), type(uint256).max );
   		wbtc.approve( address(collateralAndLiquidity), type(uint256).max );
   		weth.approve( address(collateralAndLiquidity), type(uint256).max );
   		salt.approve( address(collateralAndLiquidity), type(uint256).max );

		token.approve( address(pools), type(uint256).max );
   		wbtc.approve( address(pools), type(uint256).max );
   		weth.approve( address(pools), type(uint256).max );
   		salt.approve( address(pools), type(uint256).max );

		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, wbtc, 100 ether, 100 *10**8, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, weth, 100 ether, 100 ether, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( salt, wbtc, 100 ether, 100 *10**8, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( salt, weth, 100 ether, 100 ether, 0, block.timestamp, false );
		collateralAndLiquidity.depositCollateralAndIncreaseShare( 1000 *10**8, 1000 ether, 0, block.timestamp, false );

		pools.deposit( token, 100 ether );
		vm.stopPrank();
		}


	function _setupTokenForTesting2( IERC20 token ) public
		{
		// Whitelist the tokens with WBTC and WETH
        vm.startPrank(address(dao));
        poolsConfig.whitelistPool( pools,   token, wbtc);
        poolsConfig.whitelistPool( pools,   token, weth);
        vm.stopPrank();

		vm.startPrank(alice);
		token.approve( address(pools), type(uint256).max );
		token.approve( address(collateralAndLiquidity), type(uint256).max );

		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, wbtc, 100 ether, 100 *10**8, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, weth, 100 ether, 100 ether, 0, block.timestamp, false );

		pools.deposit( token, 100 ether );
		}


	function _setupTokenForTestingNoLiquidity( IERC20 token ) public
		{
		// Whitelist the tokens with WBTC and WETH
        vm.startPrank(address(dao));
        poolsConfig.whitelistPool( pools,   token, wbtc);
        poolsConfig.whitelistPool( pools,   token, weth);
        vm.stopPrank();

		vm.startPrank(DEPLOYER);
		wbtc.transfer(alice, 1000000 *10**8);
		weth.transfer(alice, 1000000 ether);
		salt.transfer(alice, 1000000 ether);
		vm.stopPrank();

		vm.startPrank(alice);
		token.approve( address(pools), type(uint256).max );
   		wbtc.approve( address(pools), type(uint256).max );
   		weth.approve( address(pools), type(uint256).max );
   		salt.approve( address(pools), type(uint256).max );

		token.approve( address(collateralAndLiquidity), type(uint256).max );
   		wbtc.approve( address(collateralAndLiquidity), type(uint256).max );
   		weth.approve( address(collateralAndLiquidity), type(uint256).max );
   		salt.approve( address(collateralAndLiquidity), type(uint256).max );

		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, wbtc, 100 ether, 100 *10**8, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, weth, 100 ether, 100 ether, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( salt, wbtc, 100 ether, 100 *10**8, 0, block.timestamp, false );
		collateralAndLiquidity.depositCollateralAndIncreaseShare( 1000 *10**8, 1000 ether, 0, block.timestamp, false );

		pools.deposit( token, 100 ether );
		}


	// A unit test that checks reserves and arbitrage profits are correct when then swap preceeding in the arbitrage is in the format: WBTC->WETH
	// arb: WETH->WBTC->SALT->WETH
	function testArbitrage1() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTesting(token);
		vm.startPrank(alice);

		uint256 startingWETH = weth.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( wbtc, weth, 10 *10**8, 0, block.timestamp );

		// Check the swap itself (prices not accurate)
		// 10 WBTC -> ~ 9.9 WETH
		assertEq( amountOut, 9900990099009900990 );
        assertEq( weth.balanceOf(alice) - startingWETH, 9900990099009900990 );

        // Check that the arbitrage swaps happened as expected
        (uint256 reservesA0, uint256 reservesA1) = pools.getPoolReserves(weth, wbtc);
        (uint256 reservesB0, uint256 reservesB1) = pools.getPoolReserves(wbtc, salt);
        (uint256 reservesC0, uint256 reservesC1) = pools.getPoolReserves(salt, weth);

		assertFalse( reservesA0 == (1000 ether - amountOut), "Arbitrage did not happen" );
		assertTrue( reservesA0 > ( 1000 ether - amountOut), "reservesA0 incorrect" );
		assertTrue( reservesA1 < ( 100 ether + 1*10**8), "reservesA1 incorrect" );
		assertTrue( reservesB0 > (100 * 10**8), "reservesB0 incorrect" );
		assertTrue( reservesB1 < (100 ether), "reservesB1 incorrect" );
		assertTrue( reservesC0 > (100 ether), "reservesC0 incorrect" );
		assertTrue( reservesC1 < (1000 ether), "reservesC1 incorrect" );

//		console.log( "profit: ", pools.depositedUserBalance( address(dao), weth ) );
		assertTrue( pools.depositedUserBalance( address(dao), weth ) > 2* 10**15, "arbitrage profit too low" );
		}


	// A unit test that checks reserves and arbitrage profits are correct when then swap preceeding in the arbitrage is in the format: WETH->WBTC
	// arb: WETH->SALT->WBTC->WETH
	function testArbitrage2() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTesting(token);
		vm.startPrank(alice);

		uint256 startingWBTC = wbtc.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( weth, wbtc, 10 ether, 0, block.timestamp );

		// Check the swap itself (prices not accurate)
		assertEq( amountOut, 990099009 );
        assertEq( wbtc.balanceOf(alice) - startingWBTC, 990099009 );

        // Check that the arbitrage swaps happened as expected
        (uint256 reservesA0, uint256 reservesA1) = pools.getPoolReserves(weth, salt);
        (uint256 reservesB0, uint256 reservesB1) = pools.getPoolReserves(salt, wbtc);
        (uint256 reservesC0, uint256 reservesC1) = pools.getPoolReserves(wbtc, weth);

		assertFalse( reservesA0 == (100 ether), "Arbitrage did not happen" );
		assertTrue( reservesA0 > ( 100 ether), "reservesA0 incorrect" );
		assertTrue( reservesA1 < ( 100 ether), "reservesA1 incorrect" );
		assertTrue( reservesB0 > (100 ether), "reservesB0 incorrect" );
		assertTrue( reservesB1 < (100 ether), "reservesB1 incorrect" );
		assertTrue( reservesC0 > (1000 *10**8 - amountOut), "reservesC0 incorrect" );
		assertTrue( reservesC1 < (1000 ether + 10 ether), "reservesC1 incorrect" );

//		console.log( "profit: ", pools.depositedUserBalance( address(dao), weth ) );
		assertTrue( pools.depositedUserBalance( address(dao), weth ) > 2* 10**15, "arbitrage profit too low" );
		}


	// A unit test that checks reserves and arbitrage profits are correct when then swap preceeding in the arbitrage is in the format: WETH->token
	// arb: WETH->WBTC->token->WETH
    function testArbitrage3() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTesting(token);
		vm.startPrank(alice);

		uint256 startingBalance = token.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( weth, token, 10 ether, 0, block.timestamp );

		// Check the swap itself (prices not accurate)
		assertEq( amountOut, 9090909090909090909 );
        assertEq( token.balanceOf(alice) - startingBalance, 9090909090909090909 );

        // Check that the arbitrage swaps happened as expected
        (uint256 reservesA0, uint256 reservesA1) = pools.getPoolReserves(weth, wbtc);
        (uint256 reservesB0, uint256 reservesB1) = pools.getPoolReserves(wbtc, token);
        (uint256 reservesC0, uint256 reservesC1) = pools.getPoolReserves(token, weth);

		assertFalse( reservesA0 == (1000 ether), "Arbitrage did not happen" );
		assertTrue( reservesA0 > ( 1000 ether), "reservesA0 incorrect" );
		assertTrue( reservesA1 < ( 1000 *10**8), "reservesA1 incorrect" );
		assertTrue( reservesB0 > (100 *10**8), "reservesB0 incorrect" );
		assertTrue( reservesB1 < (100 ether), "reservesB1 incorrect" );
		assertTrue( reservesC0 > (100 ether - amountOut), "reservesC0 incorrect" );
		assertTrue( reservesC1 < (1000 ether + 10 ether), "reservesC1 incorrect" );

//		console.log( "profit: ", pools.depositedUserBalance( address(dao), weth ) );
		assertTrue( pools.depositedUserBalance( address(dao), weth ) > 2* 10**15, "arbitrage profit too low" );
		}


	// A unit test that checks reserves and arbitrage profits are correct when then swap preceeding in the arbitrage is in the format: token->WETH
    // arb: WETH->token->WBTC->WETH
	function testArbitrage4() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTesting(token);
		vm.startPrank(alice);

		uint256 startingWETH = weth.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( token, weth, 1 ether, 0, block.timestamp );

		// Check the swap itself (prices not accurate)
		assertEq( amountOut, 990099009900990099 );
        assertEq( weth.balanceOf(alice) - startingWETH, 990099009900990099 );

        // Check that the arbitrage swaps happened as expected
        (uint256 reservesA0, uint256 reservesA1) = pools.getPoolReserves(weth, token);
        (uint256 reservesB0, uint256 reservesB1) = pools.getPoolReserves(token, wbtc);
        (uint256 reservesC0, uint256 reservesC1) = pools.getPoolReserves(wbtc, weth);

		assertFalse( reservesA0 == (100 ether - amountOut), "Arbitrage did not happen" );

		assertTrue( reservesA0 > ( 100 ether - amountOut), "reservesA0 incorrect" );
		assertTrue( reservesA1 < ( 100 ether + 1 ether), "reservesA1 incorrect" );
		assertTrue( reservesB0 > (100 ether), "reservesB0 incorrect" );
		assertTrue( reservesB1 < (100 * 10**8), "reservesB1 incorrect" );
		assertTrue( reservesC0 > (100 * 10**8), "reservesC0 incorrect" );
		assertTrue( reservesC1 < (1000 ether), "reservesC1 incorrect" );

		assertTrue( pools.depositedUserBalance( address(dao), weth ) > 2* 10**15, "arbitrage profit too low" );
		}


	// A unit test that checks reserves and arbitrage profits are correct when then swap preceeding in the arbitrage is in the format: token1->token2
	// arb: WETH->token2->token1->WETH
    function testArbitrage5() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.startPrank(alice);
		IERC20 token1 = new TestERC20("TEST", 18);
		IERC20 token2 = new TestERC20("TEST", 18);
		vm.stopPrank();

		_setupTokenForTesting(token1);
		vm.warp( block.timestamp + 1 hours );
		_setupTokenForTesting(token2);

        vm.prank(address(dao));
        poolsConfig.whitelistPool( pools,   token1, token2);

		vm.startPrank(alice);
		token1.approve( address(pools), type(uint256).max );
		token2.approve( address(pools), type(uint256).max );

		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token1, token2, 100 ether, 100 ether, 0, block.timestamp, false );

		uint256 startingBalance = token2.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( token1, token2, 1 ether, 0, block.timestamp );

		// Check the swap itself (prices not accurate)
		assertEq( amountOut, 990099009900990099 );
        assertEq( token2.balanceOf(alice) - startingBalance, 990099009900990099 );

        // Check that the arbitrage swaps happened as expected
        (uint256 reservesA0, uint256 reservesA1) = pools.getPoolReserves(weth, token2);
        (uint256 reservesB0, uint256 reservesB1) = pools.getPoolReserves(token2, token1);
        (uint256 reservesC0, uint256 reservesC1) = pools.getPoolReserves(token1, weth);

		assertFalse( reservesA0 == (100 ether), "Arbitrage did not happen" );
		assertTrue( reservesA0 > ( 100 ether), "reservesA0 incorrect" );
		assertTrue( reservesA1 < ( 100 ether), "reservesA1 incorrect" );
		assertTrue( reservesB0 > (100 ether - amountOut), "reservesB0 incorrect" );
		assertTrue( reservesB1 < (100 ether + 1 ether), "reservesB1 incorrect" );
		assertTrue( reservesC0 > (100 ether), "reservesC0 incorrect" );
		assertTrue( reservesC1 < (100 ether), "reservesC1 incorrect" );

//		console.log( "profit: ", pools.depositedUserBalance( address(dao), weth ) );
		assertTrue( pools.depositedUserBalance( address(dao), weth ) > 2* 10**15, "arbitrage profit too low" );
		}


	// A unit test to check that arbitrage doesn't happen when one of the pools in the arbitrage chain has liquidity less than DUST
	function testArbitrageFailed() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTestingNoLiquidity(token);
		vm.startPrank(alice);

		uint256 startingWETH = weth.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( wbtc, weth, 10 *10**8, 0, block.timestamp );

		// Check the swap itself (prices not accurate)
		assertEq( amountOut, 9900990099009900990 );
		assertEq( weth.balanceOf(alice) - startingWETH, 9900990099009900990 );

		(uint256 reservesA0,) = pools.getPoolReserves(weth, wbtc);

		assertTrue( reservesA0 == (1000 ether - amountOut), "Arbitrage should not happen" );
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "There should be no arbitrage profit" );
		}


	// A unit test that checks that multiple swaps for a single pool all yield arbitrage profit when executed consecutively
	function testSeriesOfTrades() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTesting(token);
		vm.startPrank(alice);

		for( uint256 i = 0; i < 20; i++ )
			{
			uint256 startingDepositWeth = pools.depositedUserBalance( address(dao), weth );

			pools.depositSwapWithdraw( weth, wbtc, 1 ether, 0, block.timestamp );

			uint256 profit = pools.depositedUserBalance( address(dao), weth ) - startingDepositWeth;
			assertTrue( profit > 4*10**13, "Profit lower than expected" );

//			console.log( i, profit );
			}
		}


	function _setupTokenForTestingMin( IERC20 token ) public
		{
		// Whitelist the tokens with WBTC and WETH
        vm.startPrank(address(dao));
        poolsConfig.whitelistPool( pools,   token, wbtc);
        poolsConfig.whitelistPool( pools,   token, weth);
        vm.stopPrank();

		vm.startPrank(DEPLOYER);
		wbtc.transfer(alice, 1000000 *10**8);
		weth.transfer(alice, 1000000 ether);
		salt.transfer(alice, 1000000 ether);
		vm.stopPrank();

		vm.startPrank(alice);
		token.approve( address(pools), type(uint256).max );
   		wbtc.approve( address(pools), type(uint256).max );
   		weth.approve( address(pools), type(uint256).max );
   		salt.approve( address(pools), type(uint256).max );

		token.approve( address(collateralAndLiquidity), type(uint256).max );
   		wbtc.approve( address(collateralAndLiquidity), type(uint256).max );
   		weth.approve( address(collateralAndLiquidity), type(uint256).max );
   		salt.approve( address(collateralAndLiquidity), type(uint256).max );

		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, wbtc, 100000000, 100000, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( token, weth, 100000000, 100000, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( salt, wbtc, 100000000, 100000, 0, block.timestamp, false );
		collateralAndLiquidity.depositLiquidityAndIncreaseShare( salt, weth, 100000000, 100000000, 0, block.timestamp, false );
		collateralAndLiquidity.depositCollateralAndIncreaseShare( 100000, 100000000, 0, block.timestamp, false );

		pools.deposit( token, 10000000 );
		}


	// A unit test that checks _determineProfits calculates profits correctly with reserves at minimum values.
	// arb: WETH->WBTC->SALT->WETH
	function testArbitrageReservesMin() public
		{
		assertEq( pools.depositedUserBalance( address(dao), weth ), 0, "starting deposited eth balance should be zero" );

		vm.prank(alice);
		IERC20 token = new TestERC20("TEST", 18);

		_setupTokenForTestingMin(token);
		vm.startPrank(alice);

		uint256 startingWETH = weth.balanceOf(alice);
		uint256 amountOut = pools.depositSwapWithdraw( wbtc, weth, 10000, 0, block.timestamp );

		// Check the swap itself
		assertEq( amountOut, 9090909 );
        assertEq( weth.balanceOf(alice) - startingWETH, 9090909 );

        // Check that the arbitrage swaps happened as expected
        (uint256 reservesA0, uint256 reservesA1) = pools.getPoolReserves(weth, wbtc);
        (uint256 reservesB0, uint256 reservesB1) = pools.getPoolReserves(wbtc, salt);
        (uint256 reservesC0, uint256 reservesC1) = pools.getPoolReserves(salt, weth);

		assertFalse( reservesA0 == (10000000 - amountOut), "Arbitrage did not happen" );
		assertTrue( reservesA0 > ( 10000000 - amountOut), "reservesA0 incorrect" );
		assertTrue( reservesA1 < ( 100000 + 10000), "reservesA1 incorrect" );
		assertTrue( reservesB0 > (100000), "reservesB0 incorrect" );
		assertTrue( reservesB1 < 100000000, "reservesB1 incorrect" );
		assertTrue( reservesC0 > 100000000, "reservesC0 incorrect" );
		assertTrue( reservesC1 < 100000000, "reservesC1 incorrect" );

//		console.log( "profit: ", pools.depositedUserBalance( address(dao), weth ) );
		assertEq( pools.depositedUserBalance( address(dao), weth ), 17176, "arbitrage profit incorrect" );
		}
	}


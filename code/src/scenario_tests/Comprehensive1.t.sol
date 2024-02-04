// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "forge-std/Test.sol";
import "../dev/Deployment.sol";
import "../launch/BootstrapBallot.sol";


contract TestComprehensive1 is Deployment
	{
	// User wallets for testing
    address public constant alice = address(0x1111);
    address public constant bob = address(0x2222);
    address public constant charlie = address(0x3333);
    address public constant delta = address(0x4444);


    function setUp() public
		{
		initializeContracts();

		grantAccessAlice();
		grantAccessBob();
		grantAccessCharlie();
		grantAccessDeployer();
		grantAccessDefault();


		// Give some WBTC and WETH to Alice, Bob and Charlie
		vm.startPrank(DEPLOYER);
		wbtc.transfer(alice, 1000 * 10**8 );
		wbtc.transfer(bob, 1000 * 10**8 );
		wbtc.transfer(charlie, 1000 * 10**8 );

		weth.transfer(alice, 1000 ether);
		weth.transfer(bob, 1000 ether);
		weth.transfer(charlie, 1000 ether);
		vm.stopPrank();

		// Everyone approves
		vm.startPrank(alice);
		salt.approve(address(pools), type(uint256).max);
		wbtc.approve(address(pools), type(uint256).max);
		weth.approve(address(pools), type(uint256).max);
		salt.approve(address(collateralAndLiquidity), type(uint256).max);
		wbtc.approve(address(collateralAndLiquidity), type(uint256).max);
		weth.approve(address(collateralAndLiquidity), type(uint256).max);
		vm.stopPrank();

		vm.startPrank(bob);
		salt.approve(address(pools), type(uint256).max);
		wbtc.approve(address(pools), type(uint256).max);
		weth.approve(address(pools), type(uint256).max);
		salt.approve(address(collateralAndLiquidity), type(uint256).max);
		wbtc.approve(address(collateralAndLiquidity), type(uint256).max);
		weth.approve(address(collateralAndLiquidity), type(uint256).max);
		vm.stopPrank();

		vm.startPrank(charlie);
		salt.approve(address(pools), type(uint256).max);
		wbtc.approve(address(pools), type(uint256).max);
		weth.approve(address(pools), type(uint256).max);
		salt.approve(address(collateralAndLiquidity), type(uint256).max);
		wbtc.approve(address(collateralAndLiquidity), type(uint256).max);
		weth.approve(address(collateralAndLiquidity), type(uint256).max);
		wbtc.approve(address(collateralAndLiquidity), type(uint256).max);
		weth.approve(address(collateralAndLiquidity), type(uint256).max);
		vm.stopPrank();
		}


	function testComprehensive() public
		{
		// Cast votes for the BootstrapBallot so that the initialDistribution can happen
		bytes memory sig = abi.encodePacked(aliceVotingSignature);
		vm.startPrank(alice);
		bootstrapBallot.vote(true, sig);
		vm.stopPrank();

		sig = abi.encodePacked(bobVotingSignature);
		vm.startPrank(bob);
		bootstrapBallot.vote(true, sig);
		vm.stopPrank();

		sig = abi.encodePacked(charlieVotingSignature);
		vm.startPrank(charlie);
		bootstrapBallot.vote(false, sig);
		vm.stopPrank();

		// Finalize the ballot to distribute SALT to the protocol contracts and start up the exchange
		vm.warp( bootstrapBallot.completionTimestamp() );
		bootstrapBallot.finalizeBallot();

		// Have alice, bob and charlie claim their xSALT airdrop
		vm.prank(alice);
		airdrop.claimAirdrop();
		vm.prank(bob);
		airdrop.claimAirdrop();
		vm.prank(charlie);
		airdrop.claimAirdrop();

		console.log( "alice xSALT: ", staking.userXSalt(alice) );
		console.log( "bob xSALT: ", staking.userXSalt(bob) );
		console.log( "charlie xSALT: ", staking.userXSalt(charlie) );

		// Wait a day so that alice, bob and charlie receive some SALT emissions for their xSALT
		vm.warp( block.timestamp + 1 days );
		upkeep.performUpkeep();

		bytes32[] memory poolIDs = new bytes32[](1);
		poolIDs[0] = PoolUtils.STAKED_SALT;

		vm.prank(alice);
		staking.claimAllRewards(poolIDs);
		vm.prank(bob);
		staking.claimAllRewards(poolIDs);
		vm.prank(charlie);
		staking.claimAllRewards(poolIDs);

		console.log( "alice SALT: ", salt.balanceOf(alice) );
		console.log( "bob SALT: ", salt.balanceOf(bob) );
		console.log( "charlie SALT: ", salt.balanceOf(charlie) );

		// No liquidity exists yet

		// Alice adds some SALT/WETH, AND SALT/WBTC
		vm.startPrank(alice);
		salt.approve(address(collateralAndLiquidity), type(uint256).max);
		weth.approve(address(collateralAndLiquidity), type(uint256).max);
		wbtc.approve(address(collateralAndLiquidity), type(uint256).max);

		collateralAndLiquidity.depositLiquidityAndIncreaseShare(salt, weth, 1000 ether, 10 ether, 0, block.timestamp, false);
		collateralAndLiquidity.depositLiquidityAndIncreaseShare(salt, wbtc, 1000 ether, 10 * 10**8, 0, block.timestamp, false);
		vm.stopPrank();

		// Bob adds some WBTC/WETH liquidity and borrows some USDS
		vm.startPrank(bob);
		salt.approve(address(collateralAndLiquidity), type(uint256).max);
		weth.approve(address(collateralAndLiquidity), type(uint256).max);
		wbtc.approve(address(collateralAndLiquidity), type(uint256).max);

    	collateralAndLiquidity.depositCollateralAndIncreaseShare(1000 * 10**8, 1000 ether, 0, block.timestamp, false);
    	collateralAndLiquidity.borrowUSDS( collateralAndLiquidity.maxBorrowableUSDS(bob));
    	vm.stopPrank();

    	console.log( "bob USDS: ", usds.balanceOf(bob) );

    	// Charlie places some trades
    	vm.startPrank(charlie);
    	uint256 amountOut1 = pools.depositSwapWithdraw(weth, salt, 1 ether, 0, block.timestamp);
    	uint256 amountOut2 = pools.depositSwapWithdraw(weth, salt, 1 ether, 0, block.timestamp);
		vm.stopPrank();

		console.log( "ARBITRAGE PROFITS: ", pools.depositedUserBalance( address(dao), weth ) );

    	console.log( "charlie swapped SALT:", amountOut1 );
    	console.log( "charlie swapped SALT:", amountOut2 );

		console.log( "CURRENT REWARDS FOR CALLING: ", upkeep.currentRewardsForCallingPerformUpkeep() );

    	vm.warp( block.timestamp + 1 hours );

    	vm.prank(delta);
    	upkeep.performUpkeep();

    	console.log( "delta BALANCE: ", weth.balanceOf(address(delta)) );
    	}
	}

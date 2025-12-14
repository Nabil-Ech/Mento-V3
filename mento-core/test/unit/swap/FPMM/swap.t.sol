// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable func-name-mixedcase
pragma solidity ^0.8;

import { FPMMBaseTest } from "./FPMMBaseTest.sol";
import { IOracleAdapter } from "contracts/interfaces/IOracleAdapter.sol";
import { IERC20 } from "openzeppelin-contracts-next/contracts/token/ERC20/IERC20.sol";
import { IFPMM } from "contracts/interfaces/IFPMM.sol";
import { ITradingLimitsV2 } from "contracts/interfaces/ITradingLimitsV2.sol";

contract FPMMSwapTest is FPMMBaseTest {
  function setUp() public override {
    super.setUp();
  }

  function test_swap_whenCalledWith0AmountOut_shouldRevert() public initializeFPMM_withDecimalTokens(18, 18) {
    vm.expectRevert(IFPMM.InsufficientOutputAmount.selector);
    fpmm.swap(0, 0, address(this), "");
  }

  function test_swap_oracle()
    public
    initializeFPMM_withDecimalTokens(18, 18)
    mintInitialLiquidity(18, 18)
    withOracleRate(1e18, 1e5)
    withFXMarketOpen(true)
    withRecentRate(true)
  {
    uint256 amount0In = 100e18;
    uint256 amount1Out = 99.70e18;

    uint256 initialReserve0 = fpmm.reserve0();
    uint256 initialReserve1 = fpmm.reserve1();

    vm.startPrank(ALICE);
    IERC20(token0).transfer(address(fpmm), amount0In);
    fpmm.swap(0, amount1Out, CHARLIE, "");
    vm.stopPrank();

    assertEq(IERC20(token1).balanceOf(CHARLIE), amount1Out);

    assertEq(fpmm.reserve0(), initialReserve0 + amount0In);
    assertEq(fpmm.reserve1(), initialReserve1 - amount1Out);
  }
}
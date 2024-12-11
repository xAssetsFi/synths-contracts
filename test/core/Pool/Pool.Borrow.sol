// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./_Pool.Setup.sol";

import {IPool} from "src/interface/IPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PoolBorrowTest is PoolSetup {
    uint256 amountSuppliedXFI = 1e22;
    uint256 amountSuppliedWBTC = 1e16;

    function _afterSetup() internal override {
        super._afterSetup();
        pool.supply(address(wxfi), amountSuppliedXFI);
        pool.supply(address(wbtc), amountSuppliedWBTC);
    }

    // this test coverage health factor changes (1, type(uint256).max]
    function testFuzz_borrow(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount <= poolDataProvider.maxXUSDBorrow(address(this)));

        uint256 targetShares = pool.convertToShares(amount);
        assertNotEq(targetShares, 0);

        assertEq(xusd.balanceOf(address(this)), 0);
        pool.borrow(amount, address(this));
        assertEq(xusd.balanceOf(address(this)), amount);

        assertEq(debtShares.balanceOf(address(this)), targetShares);
        assertGt(
            pool.getHealthFactor(address(this)),
            pool.getMinHealthFactorForBorrow()
        );
        assertNotEq(pool.getHealthFactor(address(this)), type(uint256).max);
    }

    function test_borrow_max() public {
        pool.borrow(
            poolDataProvider.maxXUSDBorrow(address(this)),
            address(this)
        );

        assertEq(
            pool.getHealthFactor(address(this)),
            pool.getMinHealthFactorForBorrow()
        );
    }

    function test_cooldown() public {
        pool.borrow(1, address(this));

        pool.setCooldownPeriod(12 hours);

        vm.expectRevert(IPool.Cooldown.selector);
        pool.repay(1);

        vm.warp(block.timestamp + 12 hours + 1);
        pool.repay(1);
    }

    function test_borrow_fee() public {
        vm.startPrank(user);

        IERC20(wbtc).approve(address(pool), 1000 ether);

        pool.supply(address(wbtc), 1000 ether);

        pool.borrow(100 ether, user);

        assertEq(IERC20(xusd).balanceOf(user), 99 ether);
        assertEq(IERC20(xusd).balanceOf(address(this)), 1 ether);
        assertEq(debtShares.balanceOf(user), 100 ether);
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./_DebtShares.Setup.sol";

contract DebtSharesRewarderMathTest is DebtSharesSetup {
    function _afterSetup() internal override {
        super._afterSetup();
        exchanger.setSwapFee(0);
        exchanger.setBurntAtSwap(0);
        exchanger.setRewarderFee(PRECISION);
    }

    function testFuzz_earned_differentPeriods_oneUser(uint256 period) public {
        vm.assume(period < debtShares.duration());

        uint256 amountXUSD = 100 ether;
        _supplyAndBorrow(amountXUSD);
        _swap(address(xusd), address(tesla), amountXUSD);

        skip(period);

        uint256 earned = debtShares.earned(address(xusd), address(this));
        assertApproxEqAbs(
            earned,
            (amountXUSD * period) / debtShares.duration(),
            1e6
        );
    }

    function test_earned_twoUsers_sameStart() public {
        uint256 duration = debtShares.duration();

        uint256 amountXUSD = 100 ether;
        uint256 swapAmount = 50 ether;
        _supplyAndBorrow(amountXUSD);

        vm.startPrank(user);
        _supplyAndBorrow(amountXUSD, user);
        _swap(address(xusd), address(tesla), swapAmount, user);
        vm.stopPrank();

        _swap(address(xusd), address(tesla), swapAmount, address(this));

        skip(duration);

        uint256 earnedThis = debtShares.earned(address(xusd), address(this));
        uint256 earnedUser = debtShares.earned(address(xusd), user);
        assertApproxEqAbs(earnedThis, swapAmount, 1e6);
        assertApproxEqAbs(earnedUser, swapAmount, 1e6);
    }

    function test_earned_twoUsers_differentStart() public {
        uint256 duration = debtShares.duration();

        uint256 amountXUSDBeforeFee = 100 ether;
        uint256 swapAmount = 50 ether;

        _supplyAndBorrow(amountXUSDBeforeFee);
        _swap(address(xusd), address(tesla), swapAmount, address(this));
        assertEq(xusd.balanceOf(address(debtShares)), swapAmount);

        skip(duration / 2);

        uint256 earnedThis = debtShares.earned(address(xusd), address(this));
        uint256 earnedUser = debtShares.earned(address(xusd), user);
        /*
            this swaps 50
            rewarder fee is 100%
            passed half of duration
            earned is half of swap amount
        */
        assertApproxEqAbs(earnedThis, swapAmount / 2, 1e6);
        assertEq(earnedUser, 0);

        vm.startPrank(user);
        _supplyAndBorrow(amountXUSDBeforeFee, user);
        _swap(address(xusd), address(tesla), swapAmount, user);
        vm.stopPrank();

        skip(duration);

        earnedThis = debtShares.earned(address(xusd), address(this));
        earnedUser = debtShares.earned(address(xusd), user);
        /*
            this swaps 50
            after half of duration user swaps 50
            one duration passed

            this earned:
            1) 1/2 of first swap
            2) half of 1/2 of first swap
            3) 1/2 of second swap
            total: 1/2 + 1/4 + 1/2 = 1.25

            user earned:
            1) half of 1/2 of first swap
            2) 1/2 of second swap
            total: 1/4 + 1/2 = 0.75
        */
        assertApproxEqAbs(
            earnedThis + earnedUser,
            xusd.balanceOf(address(debtShares)),
            1e8
        );
        assertGt(xusd.balanceOf(address(debtShares)), earnedThis + earnedUser);
        assertApproxEqAbs(earnedThis + earnedUser, 2 * swapAmount, 1e8);
        assertApproxEqAbs(earnedThis, swapAmount + swapAmount / 4, 1e8);
        assertApproxEqAbs(earnedUser, swapAmount / 4 + swapAmount / 2, 1e8);
    }
}

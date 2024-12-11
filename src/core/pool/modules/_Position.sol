// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Math} from "./_Math.sol";

import {IPool} from "src/interface/IPool.sol";
import {ISynth} from "src/interface/platforms/synths/ISynth.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {PoolArrayLib} from "src/lib/PoolArrayLib.sol";
import {Math as OZMathLib} from "@openzeppelin/contracts/utils/math/Math.sol";

abstract contract Position is Math {
    using SafeERC20 for IERC20;
    using SafeERC20 for ISynth;
    using PoolArrayLib for CollateralData[];

    function _supply(
        address positionOwner,
        address token,
        uint256 amount
    ) internal noZeroUint(amount) {
        Position storage position = _positions[positionOwner];

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        int8 index = position.collaterals.getIndex(token);

        if (index == -1)
            position.collaterals.push(CollateralData(token, amount));
        else position.collaterals[uint8(index)].amount += amount;

        _checkHealthFactor(positionOwner, WAD);

        emit Supply(positionOwner, token, amount);
    }

    function _withdraw(
        address positionOwner,
        address token,
        uint256 amount,
        address to
    ) internal noZeroUint(amount) {
        Position storage position = _positions[positionOwner];

        int8 index = position.collaterals.getIndex(token);
        if (index == -1) revert NotCollateralToken();

        position.collaterals[uint8(index)].amount -= amount;
        IERC20(token).safeTransfer(to, amount);

        if (position.collaterals[uint8(index)].amount == 0)
            position.collaterals.remove(token);

        _checkHealthFactor(positionOwner, getMinHealthFactorForBorrow());

        emit Withdraw(
            positionOwner,
            token,
            amount,
            to,
            !isPositionExist(positionOwner)
        );
    }

    function _repay(
        address positionOwner,
        uint256 shares
    ) internal noZeroUint(shares) {
        uint256 xusdAmount = convertToAssets(shares);

        debtShares.burn(positionOwner, shares);

        provider().xusd().burn(msg.sender, xusdAmount);

        _checkHealthFactor(positionOwner, WAD);

        emit Repay(
            positionOwner,
            xusdAmount,
            debtShares.balanceOf(positionOwner)
        );
    }

    function _borrow(
        address positionOwner,
        uint256 xusdAmount,
        address to
    ) internal noZeroUint(xusdAmount) {
        debtShares.mint(positionOwner, convertToShares(xusdAmount));

        _checkHealthFactor(positionOwner, getMinHealthFactorForBorrow());

        ISynth xusd = provider().xusd();

        uint256 fee = OZMathLib.mulDiv(xusdAmount, loanFee, PRECISION);

        xusd.mint(to, xusdAmount - fee);
        xusd.mint(feeReceiver, fee);

        _positions[positionOwner].lastBorrowTimestamp = block.timestamp;

        emit Borrow(positionOwner, xusdAmount, to);
    }

    function _liquidate(
        address positionOwner,
        address collateralToken,
        uint256 shares,
        address to
    ) internal noZeroUint(shares) {
        Position storage position = _positions[positionOwner];

        ISynth xusd = provider().xusd();
        uint256 xusdAmount = convertToAssets(shares);

        debtShares.burn(positionOwner, shares);
        xusd.burn(msg.sender, xusdAmount);

        (
            uint256 base,
            uint256 bonus,
            uint256 penalty
        ) = calculateDeductionsWhileLiquidation(collateralToken, xusdAmount);

        uint8 i = uint8(position.collaterals.getIndex(collateralToken));

        if (position.collaterals[i].amount < base + bonus + penalty)
            revert NotEnoughCollateral(
                base + bonus + penalty,
                position.collaterals[i].amount
            );

        position.collaterals[i].amount -= base + bonus + penalty;
        IERC20(collateralToken).safeTransfer(to, base + bonus);
        IERC20(collateralToken).safeTransfer(feeReceiver, penalty);

        if (position.collaterals[i].amount == 0)
            position.collaterals.remove(collateralToken);

        emit Liquidate(positionOwner, collateralToken, shares, to);
    }

    function _checkHealthFactor(
        address positionOwner,
        uint256 minHealthFactor
    ) internal view {
        Position storage position = _positions[positionOwner];

        uint256 healthFactor = calculateHealthFactor(
            position.collaterals,
            debtShares.balanceOf(positionOwner)
        );

        if (healthFactor < minHealthFactor)
            revert HealthFactorTooLow(healthFactor, minHealthFactor);
    }

    function isPositionExist(address user) public view returns (bool) {
        return _positions[user].collaterals.length > 0;
    }
}

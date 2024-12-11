// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IPool} from "src/interface/IPool.sol";
import {WETHGateway} from "./modules/_WETHGateway.sol";
import {IWETH} from "src/interface/external/IWETH.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ArrayLib} from "src/lib/ArrayLib.sol";

/// @notice Pool contract
/// @dev Inheritance:
/// Base -> UUPSProxy -> Math -> Position -> WETHGateway -> Pool
contract Pool is WETHGateway {
    function initialize(
        address _owner,
        address _provider,
        address _weth,
        address _debtShares,
        uint32 _collateralRatio,
        uint32 _liquidationRatio,
        uint32 _liquidationPenaltyPercentagePoint,
        uint32 _liquidationBonusPercentagePoint,
        uint32 _loanFee,
        uint32 _cooldownPeriod
    ) public initializer {
        __Math_init(
            _owner,
            _debtShares,
            _collateralRatio,
            _liquidationRatio,
            _liquidationPenaltyPercentagePoint,
            _liquidationBonusPercentagePoint,
            _loanFee,
            _cooldownPeriod
        );
        __UUPSProxy_init(_owner, _provider);
        __WETHGateway_init(_weth);
        _afterInitialize();
    }

    function supply(
        address token,
        uint256 amount
    ) external noPaused isCollateral(token) {
        _supply(msg.sender, token, amount);
    }

    function withdraw(
        address token,
        uint256 amount,
        address to
    ) external noPaused isPosExist(msg.sender) isCollateral(token) {
        _withdraw(msg.sender, token, amount, to);
    }

    function borrow(
        uint256 xusdAmount,
        address to
    ) public override noPaused isPosExist(msg.sender) {
        _borrow(msg.sender, xusdAmount, to);
    }

    function repay(
        uint256 shares
    )
        external
        noPaused
        isPosExist(msg.sender)
        isCooldown(_positions[msg.sender].lastBorrowTimestamp)
    {
        uint256 sharesBalance = debtShares.balanceOf(msg.sender);
        uint256 amountToRepay = shares;

        if (shares > sharesBalance) amountToRepay = sharesBalance;

        _repay(msg.sender, amountToRepay);

        if (shares == type(uint256).max) {
            Position memory position = _positions[msg.sender];

            for (uint256 i = 0; i < position.collaterals.length; i++)
                _withdraw(
                    msg.sender,
                    position.collaterals[i].token,
                    position.collaterals[i].amount,
                    msg.sender
                );
        }
    }

    function liquidate(
        address user,
        address token,
        uint256 shares,
        address to
    ) external noPaused isPosExist(user) isCollateral(token) {
        uint256 healthFactor = calculateHealthFactor(
            _positions[user].collaterals,
            debtShares.balanceOf(user)
        );

        if (healthFactor >= WAD) revert PositionHealthy();

        uint256 positionShares = debtShares.balanceOf(user);

        if (shares * 2 > positionShares)
            revert LiquidationAmountTooHigh(shares, positionShares / 2);

        _liquidate(user, token, shares, to);
    }

    function supplyAndBorrow(
        address token,
        uint256 supplyAmount,
        uint256 borrowXusdAmount,
        address borrowTo
    ) external noPaused isCollateral(token) {
        _supply(msg.sender, token, supplyAmount);
        _borrow(msg.sender, borrowXusdAmount, borrowTo);
    }

    function getHealthFactor(
        address user
    ) external view isPosExist(user) returns (uint256) {
        return
            calculateHealthFactor(
                _positions[user].collaterals,
                debtShares.balanceOf(user)
            );
    }

    function getPosition(
        address user
    ) external view isPosExist(user) returns (Position memory) {
        return _positions[user];
    }

    function collateralTokens() external view returns (address[] memory) {
        return _collateralTokens;
    }

    /* ======== Admin Functions ======== */

    function addCollateralToken(address token) external onlyOwner {
        _collateralTokens.push(token);
        isCollateralToken[token] = true;
        emit CollateralTokenAdded(token);
    }

    function removeCollateralToken(address token) external onlyOwner {
        ArrayLib.remove(_collateralTokens, token);
        isCollateralToken[token] = false;
        emit CollateralTokenRemoved(token);
    }

    function setCollateralRatio(uint32 ratio) external onlyOwner {
        collateralRatio = ratio;
        emit CollateralRatioSet(ratio);
    }

    function setLiquidationRatio(uint32 ratio) external onlyOwner {
        liquidationRatio = ratio;
        emit LiquidationRatioSet(ratio);
    }

    function setLiquidationPenaltyPercentagePoint(
        uint32 percentagePoint
    ) external onlyOwner {
        liquidationPenaltyPercentagePoint = percentagePoint;
        emit LiquidationPenaltyPercentagePointSet(percentagePoint);
    }

    function setLiquidationBonusPercentagePoint(
        uint32 percentagePoint
    ) external onlyOwner {
        liquidationBonusPercentagePoint = percentagePoint;
        emit LiquidationBonusPercentagePointSet(percentagePoint);
    }

    function setLoanFee(uint32 fee) external onlyOwner {
        loanFee = fee;
        emit LoanFeeSet(fee);
    }

    function setCooldownPeriod(uint32 period) external onlyOwner {
        cooldownPeriod = period;
        emit CooldownPeriodSet(period);
    }

    /* ======== MODIFIERS ======== */

    modifier isCooldown(uint256 lastBorrowTimestamp) {
        if (block.timestamp - lastBorrowTimestamp < cooldownPeriod)
            revert Cooldown();

        _;
    }

    function initialize(address, address) public pure override {
        revert DeprecatedInitializer();
    }

    function _afterInitialize() internal override {
        _registerInterface(type(IPool).interfaceId);
    }
}

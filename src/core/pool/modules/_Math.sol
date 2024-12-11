// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {UUPSProxy} from "src/common/_UUPSProxy.sol";

import {IPool} from "src/interface/IPool.sol";
import {IOracleAdapter} from "src/interface/IOracleAdapter.sol";
import {IDebtShares} from "src/interface/IDebtShares.sol";
import {IPlatform} from "src/interface/platforms/IPlatform.sol";

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Math as OZMathLib} from "@openzeppelin/contracts/utils/math/Math.sol";

abstract contract Math is UUPSProxy, IPool {
    IDebtShares public debtShares;
    address public feeReceiver;

    uint32 public collateralRatio;
    uint32 public liquidationRatio;

    uint32 public liquidationPenaltyPercentagePoint;
    uint32 public liquidationBonusPercentagePoint;

    uint32 public loanFee;

    /// @notice Cooldown period to execute repay after borrow
    uint32 public cooldownPeriod;

    mapping(address user => Position) internal _positions;

    mapping(address token => bool isCollateral) public isCollateralToken;
    address[] internal _collateralTokens;

    function __Math_init(
        address _feeReceiver,
        address _debtShares,
        uint32 _collateralRatio,
        uint32 _liquidationRatio,
        uint32 _liquidationPenaltyPercentagePoint,
        uint32 _liquidationBonusPercentagePoint,
        uint32 _loanFee,
        uint32 _cooldownPeriod
    )
        internal
        onlyInitializing
        noZeroAddress(_feeReceiver)
        noZeroAddress(_debtShares)
        validInterface(_debtShares, type(IDebtShares).interfaceId)
    {
        collateralRatio = _collateralRatio;
        liquidationRatio = _liquidationRatio;
        liquidationPenaltyPercentagePoint = _liquidationPenaltyPercentagePoint;
        liquidationBonusPercentagePoint = _liquidationBonusPercentagePoint;
        loanFee = _loanFee;
        cooldownPeriod = _cooldownPeriod;

        feeReceiver = _feeReceiver;
        debtShares = IDebtShares(_debtShares);
    }

    function calculateHealthFactor(
        CollateralData[] memory collateralData,
        uint256 shares
    ) public view returns (uint256 hf) {
        if (shares == 0) return type(uint256).max;

        uint256 totalUsdCollateralValue = totalPositionCollateralValue(
            collateralData
        );

        uint256 totalDebt = convertToAssets(shares);

        hf = OZMathLib.mulDiv(
            totalUsdCollateralValue,
            WAD,
            (totalDebt * liquidationRatio) / PRECISION
        );

        // hf =
        //     (WAD * totalUsdCollateralValue) /
        //     ((totalDebt * liquidationRatio) / PRECISION);
    }

    function totalPositionCollateralValue(
        CollateralData[] memory collaterals
    ) public view returns (uint256 collateralValue) {
        for (uint i = 0; i < collaterals.length; i++) {
            collateralValue += calculateCollateralValue(
                collaterals[i].token,
                collaterals[i].amount
            );
        }
    }

    function calculateCollateralValue(
        address token,
        uint256 amount
    ) public view returns (uint256 collateralValue) {
        IOracleAdapter oracle = provider().oracle();

        uint256 collateralAmount = (amount * WAD) /
            (10 ** IERC20Metadata(token).decimals());

        uint256 collateralPrice = oracle.getPrice(token);

        collateralValue = OZMathLib.mulDiv(
            collateralAmount,
            collateralPrice,
            oracle.precision()
        );

        // collateralValue =
        //     (collateralAmount * collateralPrice) /
        //     oracle.precision();
    }

    function totalFundsOnPlatforms() public view returns (uint256 tf) {
        IPlatform[] memory platforms = provider().platforms();

        for (uint i = 0; i < platforms.length; i++)
            tf += platforms[i].totalFunds();
    }

    function pricePerShare() public view returns (uint256 pps) {
        uint256 tf = totalFundsOnPlatforms();
        uint256 ts = debtShares.totalSupply();

        if (tf == 0 || ts == 0) return WAD;

        pps = OZMathLib.mulDiv(tf, WAD, ts);
    }

    function getMinHealthFactorForBorrow() public view returns (uint256 hf) {
        hf = OZMathLib.mulDiv(collateralRatio, WAD, liquidationRatio);
    }

    function convertToAssets(
        uint256 shares
    ) public view returns (uint256 assets) {
        uint256 xusdPrecision = 10 ** provider().xusd().decimals();
        assets = OZMathLib.mulDiv(
            shares,
            pricePerShare() * xusdPrecision,
            WAD * WAD
        );
    }

    function convertToShares(
        uint256 assets
    ) public view returns (uint256 shares) {
        uint256 xusdPrecision = 10 ** provider().xusd().decimals();
        shares = OZMathLib.mulDiv(
            assets,
            WAD * WAD,
            pricePerShare() * xusdPrecision
        );
    }

    function calculateDeductionsWhileLiquidation(
        address token,
        uint256 xusdAmount
    ) public view returns (uint256 base, uint256 bonus, uint256 penalty) {
        uint256 tokenDecimalsDelta = 10 **
            (18 - IERC20Metadata(token).decimals());

        IOracleAdapter oracle = provider().oracle();

        uint256 collateralPrice = oracle.getPrice(token);
        uint256 oraclePrecision = oracle.precision();

        // amount in collateral token, equivalent to amountXUSDToRepay
        base =
            OZMathLib.mulDiv(xusdAmount, oraclePrecision, collateralPrice) /
            tokenDecimalsDelta;

        // bonus for liquidator in collateral token
        bonus =
            OZMathLib.mulDiv(
                base,
                liquidationBonusPercentagePoint,
                tokenDecimalsDelta
            ) /
            PRECISION;

        // penalty to platform due liquidation in collateral token
        penalty =
            OZMathLib.mulDiv(
                base,
                liquidationPenaltyPercentagePoint,
                tokenDecimalsDelta
            ) /
            PRECISION;
    }
}

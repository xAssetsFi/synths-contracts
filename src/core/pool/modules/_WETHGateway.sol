// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Position} from "./_Position.sol";
import {IWETH} from "src/interface/external/IWETH.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract WETHGateway is Position {
    IWETH public weth;

    using SafeERC20 for IWETH;

    function __WETHGateway_init(
        address _weth
    ) internal onlyInitializing noZeroAddress(_weth) {
        weth = IWETH(_weth);
    }

    function supplyETH() public payable noPaused {
        weth.deposit{value: msg.value}();
        weth.safeTransfer(msg.sender, msg.value);

        _supply(msg.sender, address(weth), msg.value);
    }

    function withdrawETH(
        uint256 amount,
        address to
    ) public noPaused isPosExist(msg.sender) {
        _withdraw(msg.sender, address(weth), amount, address(this));

        weth.withdraw(amount);
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    function supplyETHAndBorrow(
        uint256 borrowXusdAmount,
        address borrowTo
    ) public payable noPaused {
        supplyETH();
        _borrow(msg.sender, borrowXusdAmount, borrowTo);
    }

    /* ======== Modifiers ======== */

    modifier isCollateral(address token) {
        if (!isCollateralToken[token]) revert NotCollateralToken();
        _;
    }

    modifier isPosExist(address user) {
        if (!isPositionExist(user)) revert PositionNotExists();
        _;
    }

    receive() external payable {}
}

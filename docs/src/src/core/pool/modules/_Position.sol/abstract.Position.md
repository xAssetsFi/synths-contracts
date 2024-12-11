# Position


**Inherits:**
[Math](/src/core/pool/modules/_Math.sol/abstract.Math.md)


## Functions
### _supply


```solidity
function _supply(address positionOwner, address token, uint256 amount) internal noZeroUint(amount);
```

### _withdraw


```solidity
function _withdraw(address positionOwner, address token, uint256 amount, address to) internal noZeroUint(amount);
```

### _repay


```solidity
function _repay(address positionOwner, uint256 shares) internal noZeroUint(shares);
```

### _borrow


```solidity
function _borrow(address positionOwner, uint256 xusdAmount, address to) internal noZeroUint(xusdAmount);
```

### _liquidate


```solidity
function _liquidate(address positionOwner, address collateralToken, uint256 shares, address to)
    internal
    noZeroUint(shares);
```

### _checkHealthFactor


```solidity
function _checkHealthFactor(address positionOwner, uint256 minHealthFactor) internal view;
```

### isPositionExist


```solidity
function isPositionExist(address user) public view returns (bool);
```


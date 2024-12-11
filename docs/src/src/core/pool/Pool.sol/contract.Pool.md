# Pool


**Inherits:**
[WETHGateway](/src/core/pool/modules/_WETHGateway.sol/abstract.WETHGateway.md)

Pool contract

*Inheritance:
Base -> UUPSProxy -> Math -> Position -> WETHGateway -> Pool*


## Functions
### initialize


```solidity
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
) public initializer;
```

### supply


```solidity
function supply(address token, uint256 amount) external noPaused isCollateral(token);
```

### withdraw


```solidity
function withdraw(address token, uint256 amount, address to)
    external
    noPaused
    isPosExist(msg.sender)
    isCollateral(token);
```

### borrow


```solidity
function borrow(uint256 xusdAmount, address to) public override noPaused isPosExist(msg.sender);
```

### repay


```solidity
function repay(uint256 shares)
    external
    noPaused
    isPosExist(msg.sender)
    isCooldown(_positions[msg.sender].lastBorrowTimestamp);
```

### liquidate


```solidity
function liquidate(address user, address token, uint256 shares, address to)
    external
    noPaused
    isPosExist(user)
    isCollateral(token);
```

### supplyAndBorrow


```solidity
function supplyAndBorrow(address token, uint256 supplyAmount, uint256 borrowXusdAmount, address borrowTo)
    external
    noPaused
    isCollateral(token);
```

### getHealthFactor


```solidity
function getHealthFactor(address user) external view isPosExist(user) returns (uint256);
```

### getPosition


```solidity
function getPosition(address user) external view isPosExist(user) returns (Position memory);
```

### collateralTokens


```solidity
function collateralTokens() external view returns (address[] memory);
```

### addCollateralToken


```solidity
function addCollateralToken(address token) external onlyOwner;
```

### removeCollateralToken


```solidity
function removeCollateralToken(address token) external onlyOwner;
```

### setCollateralRatio


```solidity
function setCollateralRatio(uint32 ratio) external onlyOwner;
```

### setLiquidationRatio


```solidity
function setLiquidationRatio(uint32 ratio) external onlyOwner;
```

### setLiquidationPenaltyPercentagePoint


```solidity
function setLiquidationPenaltyPercentagePoint(uint32 percentagePoint) external onlyOwner;
```

### setLiquidationBonusPercentagePoint


```solidity
function setLiquidationBonusPercentagePoint(uint32 percentagePoint) external onlyOwner;
```

### setLoanFee


```solidity
function setLoanFee(uint32 fee) external onlyOwner;
```

### setCooldownPeriod


```solidity
function setCooldownPeriod(uint32 period) external onlyOwner;
```

### isCooldown


```solidity
modifier isCooldown(uint256 lastBorrowTimestamp);
```

### initialize


```solidity
function initialize(address, address) public pure override;
```

### _afterInitialize


```solidity
function _afterInitialize() internal override;
```


# WETHGateway


**Inherits:**
[Position](/src/core/pool/modules/_Position.sol/abstract.Position.md)


## State Variables
### weth

```solidity
IWETH public weth;
```


## Functions
### __WETHGateway_init


```solidity
function __WETHGateway_init(address _weth) internal onlyInitializing noZeroAddress(_weth);
```

### supplyETH


```solidity
function supplyETH() public payable noPaused;
```

### withdrawETH


```solidity
function withdrawETH(uint256 amount, address to) public noPaused isPosExist(msg.sender);
```

### supplyETHAndBorrow


```solidity
function supplyETHAndBorrow(uint256 borrowXusdAmount, address borrowTo) public payable noPaused;
```

### isCollateral


```solidity
modifier isCollateral(address token);
```

### isPosExist


```solidity
modifier isPosExist(address user);
```

### receive


```solidity
receive() external payable;
```


# Base


**Inherits:**
[Errors](/src/common/_Errors.sol/contract.Errors.md), Initializable, [ERC165Registry](/src/common/_ERC165Registry.sol/abstract.ERC165Registry.md)


## State Variables
### WAD

```solidity
uint256 constant WAD = 1e18;
```


### PRECISION

```solidity
uint256 constant PRECISION = 10000;
```


## Functions
### validInterface


```solidity
modifier validInterface(address addr, bytes4 interfaceId);
```

### noZeroAddress


```solidity
modifier noZeroAddress(address addr);
```

### noZeroUint


```solidity
modifier noZeroUint(uint256 amount);
```


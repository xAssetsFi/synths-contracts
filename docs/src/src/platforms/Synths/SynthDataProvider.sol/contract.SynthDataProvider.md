# SynthDataProvider


**Inherits:**
[ISynthDataProvider](/src/interface/platforms/synths/ISynthDataProvider.sol/interface.ISynthDataProvider.md), [UUPSProxy](/src/common/_UUPSProxy.sol/abstract.UUPSProxy.md)


## Functions
### aggregateSynthData


```solidity
function aggregateSynthData(address user) public view returns (AggregateSynthData memory data);
```

### synthData


```solidity
function synthData(address synth, address user) public view returns (SynthData memory data);
```

### synthsData


```solidity
function synthsData(address user) public view returns (SynthData[] memory);
```

### getUserSynthData


```solidity
function getUserSynthData(address synth, address user) public view returns (UserSynthData memory data);
```

### previewSwap


```solidity
function previewSwap(address synthIn, address synthOut, uint256 amountIn) public view returns (uint256 amountOut);
```

### _afterInitialize


```solidity
function _afterInitialize() internal override;
```

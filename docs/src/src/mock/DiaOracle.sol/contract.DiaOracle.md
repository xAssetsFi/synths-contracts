# DiaOracle


**Inherits:**
[IDIAOracleV2](/src/interface/external/IDIAOracleV2.sol/interface.IDIAOracleV2.md), Ownable


## State Variables
### prices

```solidity
mapping(string key => uint256 price) internal prices;
```


### gasPrice

```solidity
uint256 internal gasPrice;
```


## Functions
### constructor


```solidity
constructor(string[] memory _keys, uint256[] memory _prices) Ownable(msg.sender);
```

### getValue


```solidity
function getValue(string memory key) external view returns (uint128 price, uint128 timestamp);
```

### setValue


```solidity
function setValue(string memory key, uint256 price) external onlyOwner;
```

### setValues


```solidity
function setValues(string[] memory _keys, uint256[] memory _prices) external onlyOwner;
```

### _setValues


```solidity
function _setValues(string[] memory _keys, uint256[] memory _prices) internal;
```


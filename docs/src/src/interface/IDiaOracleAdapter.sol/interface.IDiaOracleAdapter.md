# IDiaOracleAdapter


Oracle adapter interface for dai oracle


## Functions
### setKey


```solidity
function setKey(address token, string memory key) external;
```

### setDiaOracle


```solidity
function setDiaOracle(address diaOracle_) external;
```

## Events
### NewKey

```solidity
event NewKey(address token, string key);
```

### DiaOracleChanged

```solidity
event DiaOracleChanged(address oldDiaOracle, address newDiaOracle);
```


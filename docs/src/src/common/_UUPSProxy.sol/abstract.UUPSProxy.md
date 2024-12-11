# UUPSProxy


**Inherits:**
[ProviderKeeper](/src/common/_ProviderKeeper.sol/abstract.ProviderKeeper.md), OwnableUpgradeable, UUPSUpgradeable


## Functions
### constructor


```solidity
constructor();
```

### __UUPSProxy_init


```solidity
function __UUPSProxy_init(address _owner, address _provider) internal onlyInitializing;
```

### initialize


```solidity
function initialize(address _owner, address _provider) public virtual initializer;
```

### _afterInitialize


```solidity
function _afterInitialize() internal virtual;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal override onlyOwner;
```

### implementation


```solidity
function implementation() public view returns (address);
```


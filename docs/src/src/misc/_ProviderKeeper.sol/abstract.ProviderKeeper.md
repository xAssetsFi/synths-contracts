# ProviderKeeper



**Inherits:**
[Base](/src/misc/_Base.sol/abstract.Base.md)

## State Variables

### \_provider

```solidity
IProvider private _provider;
```

## Functions

### \_\_ProviderKeeper_init

```solidity
function __ProviderKeeper_init(address newProvider)
    internal
    noZeroAddress(newProvider)
    onlyInitializing
    validInterface(newProvider, type(IProvider).interfaceId);
```

### provider

```solidity
function provider() internal view noZeroAddress(address(_provider)) returns (IProvider);
```

### noPaused

```solidity
modifier noPaused();
```

# Synth


**Inherits:**
[ISynth](/src/interface/platforms/synths/ISynth.sol/interface.ISynth.md), [UUPSProxy](/src/common/_UUPSProxy.sol/abstract.UUPSProxy.md), ERC20Upgradeable


## Functions
### mint


```solidity
function mint(address to, uint256 amount) external checkAccess;
```

### burn


```solidity
function burn(address from, uint256 amount) external checkAccess;
```

### initialize


```solidity
function initialize(address _owner, address _provider, string memory _name, string memory _symbol) public initializer;
```

### checkAccess

*Modifier to check access control for minting and burning.
If the contract is the XUSD token, only the platforms and pool can call the function.
If the contract is not the XUSD token, only the platforms can call the function.*


```solidity
modifier checkAccess();
```

### _update


```solidity
function _update(address from, address to, uint256 amount) internal override isTransferable(from);
```

### isTransferable


```solidity
modifier isTransferable(address from);
```

### initialize


```solidity
function initialize(address, address) public pure override;
```

### _afterInitialize


```solidity
function _afterInitialize() internal override;
```

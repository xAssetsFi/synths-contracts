# IDebtShares


**Inherits:**
IERC20Metadata


## Functions
### mint

Mint debt shares

*only platforms can call this function*


```solidity
function mint(address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The address to mint the debt shares to|
|`amount`|`uint256`|The amount of debt shares to mint|


### burn

Burn debt shares

*only platforms can call this function*


```solidity
function burn(address from, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address to burn the debt shares from|
|`amount`|`uint256`|The amount of debt shares to burn|


### addReward

Notify the target reward amount

*only platforms and owner can call this function*


```solidity
function addReward(address token, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token to notify the reward amount for|
|`amount`|`uint256`|The amount of reward to notify|


## Events
### RewardAdded

```solidity
event RewardAdded(address indexed token, uint256 amount);
```

### RewardPaid

```solidity
event RewardPaid(address indexed user, address indexed token, uint256 amount);
```

### NewRewardToken

```solidity
event NewRewardToken(address token);
```


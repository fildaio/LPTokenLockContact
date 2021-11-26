// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract LockToken is Ownable {
    using SafeERC20 for IERC20;

    uint public withdrawTime;

    event WithdrawTimeChanged(uint time);

    constructor(uint _time) public {
        require(block.timestamp < _time, "time is illegal");
        withdrawTime = _time;
    }

    function setWithdrawalTime(uint _time) external onlyOwner {
        require(_time > withdrawTime, "new time must greate than save time");
        withdrawTime = _time;
        emit WithdrawTimeChanged(_time);
    }

    function withdraw(address _token, address _account, uint _amount) external onlyOwner {
        require(_token != address(0) && _account != address(0), "invalid parameter");
        require(block.timestamp >= withdrawTime, "can not withdraw token");

        if (IERC20(_token).balanceOf(address(this)) < _amount) {
            _amount = IERC20(_token).balanceOf(address(this));
        }

        IERC20(_token).safeTransfer(_account, _amount);
    }
}

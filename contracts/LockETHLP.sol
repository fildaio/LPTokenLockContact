// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract LockETHLP is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public lockContract;

    IUniswapV2Factory public factory;
    IUniswapV2Router02 public router;
    address public token;
    address public WNative;

    address public lp;

    constructor(address _lockContract, address _token, address _wnative, address _router) public {
        require(_lockContract != address(0), "invalid param");
        require(_token != address(0) && _wnative != address(0) && _router != address(0), "invalid param");

        lockContract = _lockContract;

        router = IUniswapV2Router02(_router);
        factory = IUniswapV2Factory(router.factory());
        lp = factory.getPair(_token, _wnative);

        token = _token;
        WNative = _wnative;

        IERC20(token).safeApprove(_router, uint(-1));
    }

    function setLockContract(address _lockContract) external onlyOwner {
        require(_lockContract != address(0), "invalid param");
        lockContract = _lockContract;
    }

    function lock() external onlyOwner {
        (uint res0, uint res1, ) = IUniswapV2Pair(lp).getReserves();

        uint balance0 = IERC20(token).balanceOf(address(this));
        uint balance1 = address(this).balance;
        require(balance0 > 0 && balance1 > 0, "one of the token balance is 0");

        uint amt0 = balance0;
        uint amt1 = amt0.mul(res1).div(res0).add(1);

        if (amt1 > balance1) {
            amt1 = balance1;
            amt0 = amt1.mul(res0).div(res1).add(1);
        }

        uint amt0Min = amt0.mul(998).div(1000);
        uint amt1Min = amt1.mul(998).div(1000);

        router.addLiquidityETH{value: amt1}(
            token,
            amt0,
            amt0Min,
            amt1Min,
            lockContract,
            block.timestamp
        );
    }

    function withdraw(address _token, address _account, uint _amount) external onlyOwner {
        require(_token != address(0) && _account != address(0), "invalid parameter");

        if (IERC20(_token).balanceOf(address(this)) < _amount) {
            _amount = IERC20(_token).balanceOf(address(this));
        }

        IERC20(_token).safeTransfer(_account, _amount);
    }

    function withdrawNative(address payable _account, uint _amount) external onlyOwner {
        require(_account != address(0), "invalid parameter");

        if (address(this).balance < _amount) {
            _amount = address(this).balance;
        }

        _account.transfer(_amount);
    }

    receive() external payable {
    }
}

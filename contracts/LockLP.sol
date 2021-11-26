// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract LockLP is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public lockContract;

    IUniswapV2Factory public factory;
    IUniswapV2Router02 public router;
    address public token0;
    address public token1;

    address public lp;

    constructor(address _lockContract, address _token0, address _token1, address _router) public {
        require(_lockContract != address(0), "invalid param");
        require(_token0 != address(0) && _token1 != address(0) && _router != address(0), "invalid param");

        lockContract = _lockContract;

        router = IUniswapV2Router02(_router);
        factory = IUniswapV2Factory(router.factory());
        lp = factory.getPair(_token0, _token1);

        if (IUniswapV2Pair(lp).token0() == _token0) {
            token0 = _token0;
            token1 = _token1;
        } else {
            token0 = _token1;
            token1 = _token0;
        }

        IERC20(token0).safeApprove(_router, uint(-1));
        IERC20(token1).safeApprove(_router, uint(-1));
    }

    function setLockContract(address _lockContract) external onlyOwner {
        require(_lockContract != address(0), "invalid param");
        lockContract = _lockContract;
    }

    function lock() external onlyOwner {
        (uint res0, uint res1, ) = IUniswapV2Pair(lp).getReserves();

        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint amt0 = balance0;
        uint amt1 = amt0.mul(res1).div(res0).add(1);

        if (amt1 > balance1) {
            amt1 = balance1;
            amt0 = amt1.mul(res0).div(res1).add(1);
        }

        uint amt0Min = amt0.mul(998).div(1000);
        uint amt1Min = amt1.mul(998).div(1000);

        router.addLiquidity(
            token0,
            token1,
            amt0,
            amt1,
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
}

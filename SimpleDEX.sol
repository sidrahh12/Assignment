// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SimpleDEX is ReentrancyGuard {
    address public owner;
    address public tokenA;
    address public tokenB;
    uint256 public exchangeRate;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    event TokenExchanged(address indexed token, uint256 amount, address indexed recipient);

    constructor(address _tokenA, address _tokenB, uint256 _exchangeRate) {
        owner = msg.sender;
        tokenA = _tokenA;
        tokenB = _tokenB;
        exchangeRate = _exchangeRate;
    }

    function setExchangeRate(uint256 _newRate) public onlyOwner {
        exchangeRate = _newRate;
    }

    function exchangeTokenAForTokenB(uint256 amountA) public nonReentrant {
        require(msg.sender != owner, "Owner cannot exchange tokens");
        require(ERC20(tokenA).allowance(msg.sender, address(this)) >= amountA, "Insufficient allowance");

        uint256 amountB = amountA * exchangeRate;
        require(ERC20(tokenB).balanceOf(address(this)) >= amountB, "Insufficient tokenB balance");

        ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        emit TokenExchanged(tokenA, amountA, msg.sender);
    }

    function exchangeTokenBForTokenA(uint256 amountB) public nonReentrant {
        require(msg.sender != owner, "Owner cannot exchange tokens");
        require(ERC20(tokenB).allowance(msg.sender, address(this)) >= amountB, "Insufficient allowance");

        uint256 amountA = amountB * exchangeRate;
        require(ERC20(tokenA).balanceOf(address(this)) >= amountA, "Insufficient tokenA balance");

        ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);

        emit TokenExchanged(tokenB, amountB, msg.sender);
    }
}
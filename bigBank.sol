// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Bank.sol";

contract BigBank is Bank {
    
    // Modifier: 存款金额必须大于 0.001 ether
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit amount must be > 0.001 ether");
        _;
    }

    // 重写 deposit 函数，添加 modifier 检查
    function deposit() public payable override minDeposit {
        super.deposit();
    }

    // 转移管理员权限
    function transferOwner(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}

contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 调用 BigBank 的 withdraw 函数
    function adminWithdraw(BigBank bank) external {
        require(msg.sender == owner, "Only admin owner can trigger withdraw");
        bank.withdraw();
    }

    // 必须实现 receive 以接收 BigBank 提现的 ETH
    receive() external payable {}
}
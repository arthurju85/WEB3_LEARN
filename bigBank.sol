// SPDX-License-Identifier: MIT
// 在 该挑战 的 Bank 合约基础之上，编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 同时 BigBank 有附加要求：
// 要求存款金额 >0.001 ether（用modifier权限控制）
// BigBank 合约支持转移管理员
// 编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) 
// adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。
// BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后
// Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。


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
    function adminWithdraw(IBank bank) external {
        require(msg.sender == owner, "Only admin owner can trigger withdraw");
        bank.withdraw();
    }

    // 必须实现 receive 以接收 BigBank 提现的 ETH
    receive() external payable {}
}
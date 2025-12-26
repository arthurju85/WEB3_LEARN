// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBank {
    function withdraw() external;
}

contract Bank is IBank {
    // 记录每个地址的存款金额
    mapping(address => uint) public balances;
    // 记录存款金额前 3 名的地址
    address[3] public topDepositors;
    // 管理员地址
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 允许直接转账 ETH 到合约 (支持 Metamask 直接发送)
    receive() external payable {
        deposit();
    }

    // 存款函数
    function deposit() public payable virtual {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        balances[msg.sender] += msg.value;
        
        _updateTop3(msg.sender);
    }

    // 仅管理员可提取所有 ETH
    function withdraw() external override {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // 内部函数：更新前 3 名逻辑
    function _updateTop3(address user) private {
        // 1. 如果用户已经在前 3 名中，重新排序即可
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i] == user) {
                _sortTop3();
                return;
            }
        }

        // 2. 如果用户不在前 3 名中，检查是否超过第 3 名（当前榜单最后一名）
        if (balances[user] > balances[topDepositors[2]]) {
            topDepositors[2] = user;
            _sortTop3();
        }
    }

    // 内部函数：对前 3 名进行降序排序
    function _sortTop3() private {
        for (uint i = 0; i < 3; i++) {
            for (uint j = i + 1; j < 3; j++) {
                if (balances[topDepositors[j]] > balances[topDepositors[i]]) {
                    address temp = topDepositors[i];
                    topDepositors[i] = topDepositors[j];
                    topDepositors[j] = temp;
                }
            }
        }
    }
}
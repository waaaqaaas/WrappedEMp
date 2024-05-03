// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract WrappedEMP is IERC20 {
    string public constant name = "Wrapped EMP";
    string public constant symbol = "WEMP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Wrap(address indexed user, uint256 amount);
    event Unwrap(address indexed user, uint256 amount);

    IERC20 public originalToken;

    constructor(IERC20 _originalToken) {
        originalToken = _originalToken;
    }

    function wrap(uint256 amount) external {
        require(
            originalToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed!"
        );
        balances[msg.sender] += amount;
        totalSupply += amount;
        emit Wrap(msg.sender, amount);
        emit Transfer(address(0), msg.sender, amount);
    }

    function unwrap(uint256 amount) external {
        require(
            balances[msg.sender] >= amount,
            "Insufficient wrapped EMP balance!"
        );
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        require(originalToken.transfer(msg.sender, amount), "Transfer failed!");
        emit Unwrap(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        _transfer(sender, recipient, amount);
        allowances[sender][msg.sender] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid recipient address");
        require(balances[from] >= value, "Insufficient balance");

        balances[from] -= value;
        balances[to] += value;

        emit Transfer(from, to, value);
    }
}

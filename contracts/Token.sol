pragma solidity ^0.4.18;

contract Token {
    // Storage Variables
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balances;

    constructor(string _name, string _symbol, uint256 _decimals, uint256 _initialSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;
    }

    // Fallback function
    // Do not accept ethers
    function() public {
        // This will throw an exception - in effect no one can purchase the coin
        assert(true == false);
    }

    // Getters
    function totalSupply() public view returns (uint) {
        return totalSupply;
    }

    function name() public view returns (string) {
        return name;
    }

    function symbol() public view returns (string) {
        return symbol;
    }

    function decimals() public view returns (uint256) {
        return decimals;
    }

    // Real Utility functions
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        // Check basic conditions
        require(balances[msg.sender] >= _value, "Balance must be grearter than money sent");
        require(_to != 0x0, "Receiver must be valid");
        require(_value > 0, "Sent amount must be positive");

        // Another check for assertion
        uint previousBalances = balances[msg.sender] + balances[_to];

        // Executes the transfer
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        // Assert that the total of before is equal to the total of now
        assert(balances[msg.sender] + balances[_to] == previousBalances);

        return true;
    }
}

pragma solidity ^0.4.18;

interface fundraise {
    function withdraw() external;
}

contract Fund {

    uint256 public balanceInWei;
    string public fundName;
    address public fundOwner;

    constructor(string _name) public {
        fundName = _name;
        fundOwner = msg.sender;
    }

    // Modifiers
    // Function that can be actioned only by the owner
    modifier onlyOwner {
        require(msg.sender == fundOwner, "Sender must be the owner of the fund");
        _;
    }

    function () public payable {

    }

    function fundName() public view returns (string) {
        return fundName;
    }

    function callWithdraw(address _currentFundraise) public onlyOwner payable {
        fundraise(_currentFundraise).withdraw();
    }

    function getBalance() public returns (uint256) {
        balanceInWei = fundOwner.balance;
        return balanceInWei;
    }
}

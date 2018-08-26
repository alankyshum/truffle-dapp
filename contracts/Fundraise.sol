pragma solidity ^0.4.18;

interface token {
    function transfer(address to, uint256 value) external;
}

contract Fundraise {

    /*

    Storage Variables - remain in memory

    */

    // Keep track of the fundraising timeline
    bool public fundraiseWasStarted = false;
    bool public fundraiseIsOpen = false;
    uint256 public deadline;

    // Keep track of the fundraising target in Ether
    uint256 public minimumTargetInWei;
    bool public targetReached = false;

    // Keep track of the amount raised so far
    uint256 public amountRaisedSoFarInWei = 0;

    // Token used as a reward for the fundraise
    // and conversion price
    token public tokenToBeUsedAsReward;
    uint256 public priceOfTokenInWei;

    // Fundraise beneficiary and owner
    address public fundraiseBeneficiary;
    address public fundraiseOwner;

    // Keep track of the Ether balances of contributors
    mapping(address => uint256) public balances;

    // Constructor
    constructor() public {
        fundraiseOwner = msg.sender;
    }

    // Modifiers
    // Function that can be actioned only by the owner
    modifier onlyOwner {
        require(msg.sender == fundraiseOwner, "Sender must be fund owner");
        _;
    }

    // Function that can be actioned only when the fundRaise
    // was started and closed
    modifier fundraiseWasStartedAndDoesNotMatterTheRest() {
        require(fundraiseWasStarted == true, "Fundraise must have been started");
        _;
    }

    modifier fundraiseWasStartedAndNowClosed() {
        require(fundraiseIsOpen == false && fundraiseWasStarted == true, "Fundraise was started but is now closed");
        _;
    }

    modifier fundraiseWasStartedAndStillOpen() {
        require(fundraiseIsOpen == true && fundraiseWasStarted == true, "Fundraise was started and still running");
        _;
    }

    modifier fundraiseWasNotYetStarted() {
        require(fundraiseIsOpen == false && fundraiseWasStarted == false, "Fundraise has not yet been started");
        _;
    }

    // Opens the fundraise, only if it was not so before
    function openFundraise(
        uint256 _timeOpenInMinutes,
        uint256 _minimumTargetInEthers,
        address _tokenToBeUsedAsReward,
        uint256 _priceOfTokenInEther,
        address _fundraiseBeneficiary
    ) public onlyOwner fundraiseWasNotYetStarted {
        fundraiseIsOpen = true;
        fundraiseWasStarted = true;
        deadline = block.timestamp + (_timeOpenInMinutes * 1 minutes);
        minimumTargetInWei = _minimumTargetInEthers * 1 ether;
        tokenToBeUsedAsReward = token(_tokenToBeUsedAsReward);
        priceOfTokenInWei = _priceOfTokenInEther * 1 ether;
        fundraiseBeneficiary = _fundraiseBeneficiary;
    }

    // At any time can check the status of fundraise
    function checkStatusOfFundraise() public fundraiseWasStartedAndDoesNotMatterTheRest {
        if (now >= deadline) {
            fundraiseIsOpen = false;
        }

        if (amountRaisedSoFarInWei >= minimumTargetInWei) {
            targetReached = true;
        }
    }

    function contributeToFundraise() public payable fundraiseWasStartedAndStillOpen {
        uint amount = msg.value;
        balances[msg.sender] += amount;
        amountRaisedSoFarInWei += amount;
        tokenToBeUsedAsReward.transfer(msg.sender, amount / priceOfTokenInWei);
    }

    function withdraw() public payable fundraiseWasStartedAndNowClosed {
        if (targetReached == false) {
            uint amount = balances[msg.sender];
            balances[msg.sender] = 0;
            if (msg.sender.send(amount)) {
                tokenToBeUsedAsReward.transfer(fundraiseOwner, amount / priceOfTokenInWei);
            }
        } else if (targetReached == true && fundraiseBeneficiary == msg.sender) {
            if (fundraiseBeneficiary.send(amountRaisedSoFarInWei)) {
            } else {
                targetReached = false;
            }
        }
    }
}

escrow.sol
//SPDX-License-Identifier:MIT
 pragma solidity 0.8.28;

contract ContestPayment {
    enum State { Initial, Funded, Completed }

    address public producer;
    address public evaluator;
    uint256 public totalPrize;
    State public state;
    
    event ContestFunded(address producer, uint256 amount);
    event PaymentSent(address winner, uint256 amount);

    modifier onlyProducer() {
        require(msg.sender == producer, "Only producer can call this");
        _;
    }

    modifier onlyEvaluator() {
        require(msg.sender == evaluator, "Only evaluator can call this");
        _;
    }

    constructor(address _evaluator) {
        producer = msg.sender;
        evaluator = _evaluator;
        state = State.Initial;
    }

    function fundContest() external payable onlyProducer {
        require(state == State.Initial, "Contest already funded");
        require(msg.value > 0, "Prize must be greater than 0");
        
        totalPrize = msg.value;
        state = State.Funded;
        
        emit ContestFunded(msg.sender, msg.value);
    }

    function distributePayments(
        address[] calldata winners,
        uint256[] calldata amounts
    ) external onlyEvaluator {
        require(state == State.Funded, "Contest not funded or already completed");
        require(winners.length > 0, "Must have at least one winner");
        require(winners.length == amounts.length, "Winners and amounts must match");
        
        uint256 totalToDistribute = 0;
        for(uint i = 0; i < amounts.length; i++) {
            totalToDistribute += amounts[i];
        }
        require(totalToDistribute <= totalPrize, "Total distribution exceeds prize pool");

        for(uint i = 0; i < winners.length; i++) {
            require(winners[i] != address(0), "Invalid winner address");
            require(amounts[i] > 0, "Amount must be greater than 0");
            
            payable(winners[i]).transfer(amounts[i]);
            emit PaymentSent(winners[i], amounts[i]);
        }
        
        // If there's any remaining balance, send it back to producer
        uint256 remaining = address(this).balance;
        if (remaining > 0) {
            payable(producer).transfer(remaining);
        }
        
        state = State.Completed;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}
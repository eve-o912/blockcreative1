// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdeaBountyExtended {
    struct Script {
        address submitter;
        string content; 
        uint256 score; 
    }

    address public producer;
    address public aiOperator;
    Script[] public scripts; 
    uint256 public submissionDeadline; 
    bool public submissionPeriodOver = false; 
    bool public rankingComplete = false; 

    event ScriptSubmitted(address indexed submitter, string content);
    event SubmissionPeriodEnded();
    event ScriptsRanked();
    event ScriptRanked(uint256 indexed scriptIndex, uint256 score);

    modifier onlyProducer() {
        require(msg.sender == producer, "Only producer can perform this action");
        _;
    }

    modifier onlyAiOperator() {
        require(msg.sender == aiOperator, "Only AI operator can perform this action");
        _;
    }

    modifier submissionPeriodActive() {
        require(block.timestamp <= submissionDeadline, "Submission period is over");
        _;
    }

    modifier submissionPeriodEnded() {
        require(block.timestamp > submissionDeadline, "Submission period is still active");
        _;
    }

    modifier rankingNotComplete() {
        require(!rankingComplete, "Ranking is already complete");
        _;
    }

    constructor(address _aiOperator, uint256 _submissionDuration) {
        producer = msg.sender;
        aiOperator = _aiOperator;
        submissionDeadline = block.timestamp + _submissionDuration;
    }

    
    function submitScript(string memory _content) public submissionPeriodActive {
        require(bytes(_content).length > 0, "Script content cannot be empty");
        scripts.push(Script(msg.sender, _content, 0)); // Store the script
        emit ScriptSubmitted(msg.sender, _content);
    }

    
    function endSubmissionPeriod() public onlyProducer {
        require(block.timestamp > submissionDeadline, "Submission period is still active");
        submissionPeriodOver = true;
        emit SubmissionPeriodEnded();
    }


    function rankScripts(uint256[] memory _scores) public onlyAiOperator submissionPeriodEnded rankingNotComplete {
        require(_scores.length == scripts.length, "Invalid scores length");
        require(scripts.length > 0, "No scripts submitted yet");

        for (uint256 i = 0; i < scripts.length; i++) {
            scripts[i].score = _scores[i];
            emit ScriptRanked(i, _scores[i]);
        }

        rankingComplete = true; 
        emit ScriptsRanked();
    }

    
    function getScripts() public view returns (Script[] memory) {
        return scripts;
    }

    
    function getTopScript() public view returns (Script memory) {
        require(rankingComplete, "Ranking is not complete yet");
        uint256 topScore = 0;
        uint256 topIndex = 0;

        for (uint256 i = 0; i < scripts.length; i++) {
            if (scripts[i].score > topScore) {
                topScore = scripts[i].score;
                topIndex = i;
            }
        }

        return scripts[topIndex];
    }
}
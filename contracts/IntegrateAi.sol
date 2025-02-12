// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ideas.sol";

contract AiIntegration {
    address public aiOperator;
    IdeaBountyExtended public ideaBounty;

    constructor(address _ideaBountyAddress) {
        aiOperator = msg.sender;
        ideaBounty = IdeaBountyExtended(_ideaBountyAddress);
    }

    
    function submitIdeaScores(uint256[] memory _scores) public {
        require(msg.sender == aiOperator, "Only AI operator can perform this action");
        ideaBounty.rankIdeas(_scores);
    }

    
    function submitSynopsisScores(uint256[] memory _scores) public {
        require(msg.sender == aiOperator, "Only AI operator can perform this action");
        ideaBounty.rankSynopses(_scores);
    }

    
    function submitTreatmentScores(uint256 _sceneNumber, uint256[] memory _scores) public {
        require(msg.sender == aiOperator, "Only AI operator can perform this action");
        ideaBounty.rankTreatments(_sceneNumber, _scores);
    }
}
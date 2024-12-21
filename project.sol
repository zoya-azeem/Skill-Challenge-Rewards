// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillChallengeRewards {
    struct Challenge {
        string title;
        string description;
        address creator;
        uint256 reward;
        bool isCompleted;
        address[] participants;
    }

    Challenge[] public challenges;
    mapping(address => uint256) public participantTokens;

    event ChallengeCreated(
        uint256 challengeId,
        string title,
        string description,
        address creator,
        uint256 reward
    );

    event ParticipantJoined(
        uint256 challengeId,
        address participant
    );

    event TokensDistributed(
        uint256 challengeId,
        uint256 reward
    );

    event TokensClaimed(
        address participant,
        uint256 amount
    );

    // Create a new challenge
    function createChallenge(
        string memory title,
        string memory description,
        uint256 reward
    ) public payable {
        require(msg.value == reward, "Reward amount must be funded.");

        address[] memory participants;
        challenges.push(Challenge({
            title: title,
            description: description,
            creator: msg.sender,
            reward: reward,
            isCompleted: false,
            participants: participants
        }));

        emit ChallengeCreated(challenges.length - 1, title, description, msg.sender, reward);
    }

    // Join a challenge
    function joinChallenge(uint256 challengeId) public {
        Challenge storage challenge = challenges[challengeId];
        require(!challenge.isCompleted, "Challenge is already completed.");

        challenge.participants.push(msg.sender);

        emit ParticipantJoined(challengeId, msg.sender);
    }

    // Mark challenge as completed and distribute rewards
    function completeChallenge(uint256 challengeId) public {
        Challenge storage challenge = challenges[challengeId];
        require(msg.sender == challenge.creator, "Only the creator can mark this challenge as completed.");
        require(!challenge.isCompleted, "Challenge is already completed.");
        require(challenge.participants.length > 0, "No participants to reward.");

        challenge.isCompleted = true;
        uint256 rewardPerParticipant = challenge.reward / challenge.participants.length;

        for (uint256 i = 0; i < challenge.participants.length; i++) {
            participantTokens[challenge.participants[i]] += rewardPerParticipant;
        }

        emit TokensDistributed(challengeId, challenge.reward);
    }

    // Claim tokens
    function claimTokens() public {
        uint256 amount = participantTokens[msg.sender];
        require(amount > 0, "No tokens to claim.");

        participantTokens[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit TokensClaimed(msg.sender, amount);
    }

    // Get all challenges
    function getAllChallenges() public view returns (Challenge[] memory) {
        return challenges;
    }
}   
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StackUp {
    enum PlayerQuestStatus {
        NOT_JOINED,
        JOINED,
        SUBMITTED
    }

    // Enum for Quest Review status
    enum QuestReviewStatus {
        REVIEWING,
        REJECTED,
        REWARDED,
        APPROVED
    }

    struct Quest {
        uint256 questId;
        uint256 numberOfPlayers;
        string title;
        uint8 reward;
        uint256 numberOfRewards;
        uint256 startTime;
        uint256 endTime;
    }

    address public admin;
    uint256 public nextQuestId;
    mapping(uint256 => Quest) public quests;
    mapping(address => mapping(uint256 => PlayerQuestStatus))
        public playerQuestStatuses;
    // Mapping to store the review status of the quests
    mapping(uint256 => mapping(address => QuestReviewStatus))
        public questReviewStatuses;

    constructor() {
        admin = msg.sender;
    }

    function createQuest(
        string calldata title_,
        uint8 reward_,
        uint256 numberOfRewards_,
        uint256 startTime_,
        uint256 endTime_
    ) external {
        require(msg.sender == admin, "Only the admin can create quests");
        quests[nextQuestId].questId = nextQuestId;
        quests[nextQuestId].title = title_;
        quests[nextQuestId].reward = reward_;
        quests[nextQuestId].numberOfRewards = numberOfRewards_;
        // assigning start and endtime to quests
        quests[nextQuestId].startTime = startTime_;
        quests[nextQuestId].endTime = endTime_;
        nextQuestId++;
    }

    function joinQuest(uint256 questId)
        external
        questExists(questId)
        // check whether the user is trying to join the quest in the required time limit
        withinTimeLimit(quests[questId].startTime, quests[questId].endTime)
    {
        require(
            playerQuestStatuses[msg.sender][questId] ==
                PlayerQuestStatus.NOT_JOINED,
            "Player has already joined/submitted this quest"
        );
        playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.JOINED;

        Quest storage thisQuest = quests[questId];
        thisQuest.numberOfPlayers++;
    }

    function submitQuest(uint256 questId)
        external
        questExists(questId)
        // check whether the user is trying to submit the quest in the required time limit
        withinTimeLimit(quests[questId].startTime, quests[questId].endTime)
    {
        // Check is player has joined the quest or not
        require(
            playerQuestStatuses[msg.sender][questId] ==
                PlayerQuestStatus.JOINED,
            "Player must first join the quest"
        );
        playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.SUBMITTED;
        // Set the quest status reviewing for the user submitting the quest
        questReviewStatuses[questId][msg.sender] = QuestReviewStatus.REVIEWING;
    }

    // Review Quest Function to review the quest submition of the user and mark it as rewarded or rejected or approved
    function reviewQuest(
        uint256 questId,
        address user,
        QuestReviewStatus status
    ) external questExists(questId) onlyAdmin notReviewed(questId, user) {
        // Checking whether user has submitted the quest or not.
        require(
            playerQuestStatuses[user][questId] == PlayerQuestStatus.SUBMITTED,
            "Player has not submitted this quest"
        );
        // get current quest data
        Quest storage thisQuest = quests[questId];
        // set the review status of the user quest submissiom
        questReviewStatuses[questId][user] = status;
        // If rewards are left for the user decrease the number of rewards for the quest 
        if (
            status == QuestReviewStatus.REWARDED &&
            thisQuest.numberOfRewards > 0
        ) {
            thisQuest.numberOfRewards--;
        }
    }

    // Check if the quest exist or not
    modifier questExists(uint256 questId) {
        require(quests[questId].reward != 0, "Quest does not exist");
        _;
    }
    
    // Check whether the caller is the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    // Modifier to check whether the quest is already
    modifier notReviewed(uint256 questId, address user) {
        require(
            questReviewStatuses[questId][user] == QuestReviewStatus.REVIEWING,
            "This Quest has already been reviewed for this user"
        );
        _;
    }

    // Modifier to check whether the user is Joining or Submitting the quest within the time limit.
    modifier withinTimeLimit(uint256 startTime, uint256 endTime) {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Quest is either on started or It has ended already."
        );
        _;
    }
}
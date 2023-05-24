# StackUp Build Your First DApp

## Introduction

This DApp is a simple clone of StackUp, in which admin can create a quest and users have to first join the quest then they can submit their answers. If the answer is correct then they will be rewarded.

## Which features I am trying to add and why?

1. **Quests can be created with a time limit.** This feature is added to make the DApp more realistic. In StackUp, there are time limits for every quest.
As feature will help to prevent the users from joining the quest before and after the set time limit since we are rewarding the users and there may be 2000+ submitions so we will need a lot of workforce to review the quests and we cannot reward a quest for the lifetime since answers will be out and everyone will be just randomly submitting for rewards.

2. **Added a functionality to Review Quests** This feature is added to make the DApp more realistic. As in StackUp, there are admins who review the quest submitions of the users and mark them as rewarded or rejected or approved. There is no purpose of bringing quests if we(admin) cannot review the submitions of the users and reward them. So, I picked this feature.


## My Work and How It works?

I have added 2 new features in this DApp:

1. **Quests can be created with a time limit.** If the user submits the answer after the time limit then he/she will not be rewarded. And the user will not be able to join the quest before and after the set time limit.

Added `startTime` and `endTime` in the `Quest` struct and added a modifier `withinTimeLimit` to check whether the user is Joining or Submitting the quest within the time limit.


```
struct Quest {
    uint256 questId;
    uint256 numberOfPlayers;
    string title;
    uint8 reward;
    uint256 numberOfRewards;
    uint256 startTime; // start time of the quest
    uint256 endTime; // end time of the quest
}
```

```
// assigning start and endtime to quests

    quests[nextQuestId].startTime = startTime_;
    quests[nextQuestId].endTime = endTime_;
```

```
// Modifier to check whether the user is Joining or Submitting the quest within the time limit.
modifier withinTimeLimit(uint256 startTime, uint256 endTime) {
    require(
        block.timestamp >= startTime && block.timestamp <= endTime,
        "Quest is either on started or It has ended already."
    );
    _;
}
```

2. **Added a functionality to Review Quests** If the user submits the quest then the admin can review the submittion if it satifies the rquirement then mark the submition rewarded or if wrong answer then mark it as rejected and if the answer answer is correct and no rewards left then it is marked approved.

Added a new enum `QuestReviewStatus` to store the review status of the quests and added a mapping `questReviewStatuses` to store the review status of the quests.

```
// Enum for Quest Review status
    enum QuestReviewStatus {
        REVIEWING,
        REJECTED,
        REWARDED,
        APPROVED
    }


// Mapping to store the review status of the quests
 mapping(uint256 => mapping(address => QuestReviewStatus))
        public questReviewStatuses;
```

```
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
```

Modiers used in the Function Review Quest :

```
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
```
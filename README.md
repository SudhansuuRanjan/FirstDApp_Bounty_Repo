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

## Working of the features

- First we compile and deploy the smart contract in Remix IDE.

- **Checking the Quest Time Limit Feature**
  #### We create a new quest by calling the function `createQuest` and passing the required parameters.
  * title : `NextJs 13`
  * reward : `12`
  * numberOfRewards : `10`
  * startTime : `1685012333` (Thursday, 25 May 2023 10:58:53 AM)
  * endTime : `1685023133` (Thursday, 25 May 2023 1:58:53 PM)



  #### We join the quest by calling the function `joinQuest` and passing the required parameters.

  ![Newly Created Quest](https://i.ibb.co/Pgs2Swc/1.png "Newly Created Quest")
    
  2. We then switch to a different account and try to join the quest before the start time and after the end time and we get the following error message.

  ![Error Message](https://i.ibb.co/92DXPxH/2.png "Error Message")

- **Checking the functionality to Review Quests**

  #### We create a new quest by calling the function `createQuest` and passing the required parameters.
  * title : `NextJs 13`
  * reward : `12`
  * numberOfRewards : `10`
  * startTime : `1685023133` (Thursday, 25 May 2023 1:58:53 PM)
  * endTime : `1685037533` (Thursday, 25 May 2023 5:58:53 PM)


  #### We join the quest by calling the function `joinQuest` and passing the required parameters.

  1. We then switch to different account and join the quest by calling the function `joinQuest` and passing the required questId `0`.

  ![Newly Created Quest](https://i.ibb.co/J2Fn9pg/3.png "Newly Created Quest")
  2. Calling Join quest from another acccount.
  ![Join Quest](https://i.ibb.co/JHL7634/4.png "Join Created Quest")
  3. Checking Quest status after joining.
  ![Check Quest Status](https://i.ibb.co/47DXDF4/5.png "Check Quest Status")
  4. Switching to the admin account and reviewing the quest submition of the user. It failed because the user an not yet submitted the quest.
  ![Quest Review Failed](https://i.ibb.co/QmgkYJB/6.png "Quest Review Failed")
  5. Switching to the user account and submitting the quest. And then observe the playerQuestStatus and questReviewStatus which are `2(Submitted)` and `0(Reviewing)`.
  ![Checking Quest Status](https://i.ibb.co/y6Px0hH/7.png "Checking Quest Status")
  6. Switching to the admin account and reviewing the quest submition of the user. We mark the quest submition as rewarded and then observe the questReviewStatus and No of Rewards left in Quest which are `2(Rewarded)` and `9` since the user is rewarded so rewards left is decrease by 1.
  ![Quest Review Success](https://i.ibb.co/VHgXkX8/8.png "Quest Review Success")
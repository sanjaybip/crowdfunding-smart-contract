// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

enum MilestoneStatus {
    Approved,
    Pending,
    Declined
}

contract CrowdFundingContract is Initializable {
    address payable private _campaignOwner;
    string public fundingCID;
    uint256 public targetAmount;
    uint256 public campaignDuration;

    //crowd funding metadata
    bool public campaignEnded;
    uint256 private _numberOfWithdrawal;
    uint256 private _numberOfDonors;
    uint256 private _amountDonated;

    uint256 private _milestoneCounter;

    struct MilestoneVote {
        address donorAddress;
        bool vote;
    }

    struct Milestone {
        string milestoneCID;
        bool approved;
        uint256 votingPeriod;
        MilestoneStatus status;
        MilestoneVote[] votes;
    }
    mapping(uint256 => Milestone) public milestones;

    mapping(address => uint256) public donors;

    event FundDonated(address indexed donor, uint256 amount, uint256 date);

    event MilestoneCreated(address indexed owner, uint256 createdDate, uint256 duration);

    event FundsWithdrawn(
        address indexed campaignOwner,
        uint256 indexed milestoneCounter,
        uint256 amount,
        uint256 numberOfWithdrawal,
        uint256 withdrawalDate
    );

    event MilestoneRejected(
        uint256 indexed milestoneCounter,
        uint256 yesVote,
        uint256 noVote,
        uint256 rejectionDate
    );

    function initialize(
        string calldata _fundingCID,
        uint256 _amount,
        uint256 _duration
    ) external initializer {
        fundingCID = _fundingCID;
        targetAmount = _amount;
        campaignDuration = _duration;
        _campaignOwner = payable(tx.origin);
    }

    function makeDonation() public payable {
        uint256 fund = msg.value;
        require(!campaignEnded, "Campaign Ended already");
        require(fund > 0, "You can not donate 0!");
        if (donors[msg.sender] == 0) {
            _numberOfDonors += 1;
        }
        donors[msg.sender] += fund;
        _amountDonated += fund;

        emit FundDonated(msg.sender, fund, block.timestamp);
    }

    function createNewMilestone(string memory _milestoneCID, uint256 _votingPeriod) public {
        require(msg.sender == _campaignOwner, "Only owner can run this function");
        require(
            milestones[_milestoneCounter].status != MilestoneStatus.Pending,
            "You have a pending milestone"
        );
        require(_numberOfWithdrawal <= 3, "No more milestone allowed");
        _milestoneCounter++;
        Milestone storage milestone = milestones[_milestoneCounter];
        milestone.milestoneCID = _milestoneCID;
        milestone.approved = false;
        milestone.votingPeriod = _votingPeriod;
        milestone.status = MilestoneStatus.Pending;

        emit MilestoneCreated(msg.sender, block.timestamp, _votingPeriod);
    }

    function voteOnMilestone(bool _vote) public {
        require(
            milestones[_milestoneCounter].status == MilestoneStatus.Pending,
            "Voting is over for this milestone"
        );
        require(
            block.timestamp <= milestones[_milestoneCounter].votingPeriod,
            "Voting is period is over"
        );
        require(donors[msg.sender] != 0, "You are not a donor!");

        uint256 counter = 0;
        uint256 milestoneVoteLength = milestones[_milestoneCounter].votes.length;
        bool voted = false;
        for (counter; counter < milestoneVoteLength; counter++) {
            MilestoneVote memory userVote = milestones[_milestoneCounter].votes[counter];
            if (userVote.donorAddress == msg.sender) {
                voted = true;
                break;
            }
        }

        if (!voted) {
            MilestoneVote memory userVote;
            userVote.donorAddress = msg.sender;
            userVote.vote = _vote;
            milestones[_milestoneCounter].votes.push(userVote);
        } else {
            revert("you already voted!");
        }
    }

    function withdrawMiltestone() public {
        require(msg.sender == _campaignOwner, "Only owner can run this function");
        require(
            milestones[_milestoneCounter].status == MilestoneStatus.Pending,
            "This milestone is completed"
        );
        require(
            block.timestamp > milestones[_milestoneCounter].votingPeriod,
            "Voting is still on"
        );

        (uint256 yesvote, uint256 novote) = calculateVote(milestones[_milestoneCounter].votes);

        uint256 totalVote = milestones[_milestoneCounter].votes.length;

        uint256 baseNumber = 10**9;

        uint256 twoThirdOfTotal = (2 * totalVote * baseNumber) / 3;
        uint256 totalYesVote = yesvote * baseNumber;
        if (totalYesVote >= twoThirdOfTotal && totalYesVote > 0) {
            milestones[_milestoneCounter].approved = true;
            milestones[_milestoneCounter].status = MilestoneStatus.Approved;
            _numberOfWithdrawal++;
            if (_numberOfWithdrawal == 3) {
                campaignEnded = true;
            }
            uint256 contractBalance = address(this).balance;
            require(contractBalance > 0, "Not enough balance to withdraw");
            uint256 amountToWithdraw;
            if (_numberOfWithdrawal == 1) {
                amountToWithdraw = contractBalance / 3;
            } else if (_numberOfWithdrawal == 2) {
                amountToWithdraw = contractBalance / 2;
            } else {
                amountToWithdraw = contractBalance;
            }
            (bool success, ) = _campaignOwner.call{value: amountToWithdraw}("");
            require(success, "withdrawal failed");
            emit FundsWithdrawn(
                _campaignOwner,
                _milestoneCounter,
                amountToWithdraw,
                _numberOfWithdrawal,
                block.timestamp
            );
        } else {
            milestones[_milestoneCounter].status = MilestoneStatus.Declined;
            milestones[_milestoneCounter].approved = false;
            emit MilestoneRejected(_milestoneCounter, yesvote, novote, block.timestamp);
        }
    }

    function calculateVote(MilestoneVote[] memory _votes) private pure returns (uint256, uint256) {
        uint256 yesVote = 0;
        uint256 noVote = 0;
        for (uint256 i = 0; i < _votes.length; i++) {
            if (_votes[i].vote == true) {
                yesVote++;
            } else {
                noVote++;
            }
        }
        return (yesVote, noVote);
    }

    //getter function
    function getDonation() public view returns (uint256) {
        return _amountDonated;
    }

    function campaignOwner() public view returns (address payable) {
        return _campaignOwner;
    }

    function numberOfDonors() public view returns (uint256) {
        return _numberOfDonors;
    }

    function showCurrentMillestone() public view returns (Milestone memory) {
        return milestones[_milestoneCounter];
    }
}

pragma solidity ^0.8.0;

contract CommunityGovernance {
    enum Vote {
        None,
        Approve,
        Reject,
        Abstain
    }
    enum ProposalStatus {
        Pending,
        Approved,
        Rejected,
        Revoked
    }

    struct Proposal {
        uint256 id;
        string description;
        uint256 deadline;
        address creator;
        ProposalStatus status;
    }

    struct VoteCount {
        uint256 approveCount;
        uint256 rejectCount;
        uint256 abstainCount;
    }

    address public contractOwner;
    uint256 private proposalCounter;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => VoteCount) public voteCounts;
    mapping(uint256 => mapping(address => Vote)) public proposalVotes;

    modifier onlyOwner() {
        require(
            msg.sender == contractOwner,
            "Only the contract owner can perform this action."
        );
        _;
    }

    modifier onlyProposalCreator(uint256 _proposalId) {
        require(
            proposals[_proposalId].creator == msg.sender,
            "Only the proposal creator can perform this action."
        );
        _;
    }

    constructor() {
        contractOwner = msg.sender;
        proposalCounter = 0;
    }

    // Register a new proposal
    function registerProposal(
        string memory _description,
        uint256 _deadline
    ) public returns (uint256) {
        require(_deadline > block.timestamp, "Invalid deadline.");
        uint256 newProposalId = ++proposalCounter;
        proposals[newProposalId] = Proposal(
            newProposalId,
            _description,
            _deadline,
            msg.sender,
            ProposalStatus.Pending
        );
        voteCounts[newProposalId] = VoteCount(0, 0, 0);
        return newProposalId;
    }

    // Revoke a proposal before the voting deadline
    function revokeProposal(
        uint256 _proposalId
    ) public onlyProposalCreator(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(
            block.timestamp < proposal.deadline,
            "Cannot revoke a proposal after the voting deadline."
        );
        proposal.status = ProposalStatus.Revoked;
    }

    // Vote on a proposal
    function vote(uint256 _proposalId, Vote _vote) public {
        Proposal storage proposal = proposals[_proposalId];
        require(
            block.timestamp < proposal.deadline,
            "Cannot vote after the voting deadline."
        );
        require(
            proposalVotes[_proposalId][msg.sender] == Vote.None,
            "User has already voted on this proposal."
        );

        proposalVotes[_proposalId][msg.sender] = _vote;
        if (_vote == Vote.Approve) {
            voteCounts[_proposalId].approveCount++;
        } else if (_vote == Vote.Reject) {
            voteCounts[_proposalId].rejectCount++;
        } else if (_vote == Vote.Abstain) {
            voteCounts[_proposalId].abstainCount++;
        }
    }

    // Check the status of a proposal
    function getProposalStatus(
        uint256 _proposalId
    ) public view returns (ProposalStatus) {
        Proposal storage proposal = proposals[_proposalId];
        if (proposal.status != ProposalStatus.Pending) {
            return proposal.status;
        }

        if (block.timestamp < proposal.deadline) {
            return ProposalStatus.Pending;
        }

        VoteCount storage voteCount = voteCounts[_proposalId];

        if (voteCount.approveCount > voteCount.rejectCount) {
            return ProposalStatus.Approved;
        } else if (voteCount.rejectCount > voteCount.approveCount) {
            return ProposalStatus.Rejected;
        } else {
            return ProposalStatus.Pending;
        }
    }

    // Execute an approved proposal (to be customized based on your requirements)
    // For example, you could create a function to execute proposals that make changes to other contracts or distribute rewards
}

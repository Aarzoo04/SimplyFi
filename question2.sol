// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Vote {

    address public winner;

    // Define voter
    struct voter {
        string name;
        uint age;
        uint voter_id;
        address voter_addr;
        uint voteCandidate_id;
        bool hasVoted;
    }

    // Define candidate
    struct candidate {
        string name;
        uint age;
        uint candidate_id;
        address candidate_address;
        uint votes;
        string party;
    }

    uint public registration_deadline = 1720963800; // 14th July 2024(7:0:0 pm) in Unix timestamp

    // You can change this deadline time for testing purpose by using epoc converter(website).

    uint nextVoter_id = 1;    // will define voter id for voters
    uint nextCandidate_id = 1; // will define candidate id for candidates

    mapping(uint => voter) public voter_details;   // will store the details of voter
    mapping(uint => candidate) public candidate_details; // storing details of candidates
    mapping(address => bool) public blacklist; // storing blacklisted voters

    // Candidate part
    function candidate_register(string memory _name, string memory _party, uint _age) external {
        // Checking conditions
        require(candidate_verification(msg.sender), "Candidate already registered !!");
        require(_age >= 18, "You are not eligible !!");

        candidate_details[nextCandidate_id] = candidate(_name, _age, nextCandidate_id, msg.sender, 0, _party);
        nextCandidate_id++;
    }

    function candidate_verification(address _caller) internal view returns (bool) {
        for (uint i = 1; i < nextCandidate_id; i++) {
            if (candidate_details[i].candidate_address == _caller) {
                return false;
            }
        }
        return true;
    }

    function candidate_list() public view returns (candidate[] memory) {
        candidate[] memory array_candidate = new candidate[](nextCandidate_id - 1);
        for (uint i = 1; i < nextCandidate_id; i++) {
            array_candidate[i - 1] = candidate_details[i];
        }
        return array_candidate;
    }

    // Voter part
    function voter_register(string memory _name, uint _age) external {
        require(block.timestamp <= registration_deadline, "Registration period has ended.");
        require(voter_verification(msg.sender), "Voter has already registered !!");
        require(_age >= 18, "Not eligible to vote");

        voter_details[nextVoter_id] = voter(_name, _age, nextVoter_id, msg.sender, 0, false);
        nextVoter_id++;
    }

    function voter_verification(address _caller) internal view returns (bool) {
        for (uint i = 1; i < nextVoter_id; i++) {
            if (voter_details[i].voter_addr == _caller) {
                return false;
            }
        }
        return true;
    }

    function vote(uint _voterId, uint _candidateId) external {
        require(!blacklist[msg.sender], "You are blacklisted from voting.");
        require(voter_details[_voterId].voter_addr == msg.sender, "You are not registered to vote.");

        voter storage _voter = voter_details[_voterId];

        if (_voter.hasVoted) {
            // Remove previous vote
            candidate_details[_voter.voteCandidate_id].votes--;
            // Blacklist the voter
            blacklist[_voter.voter_addr] = true;
            // Reset voter's vote status and candidate ID
            _voter.hasVoted = false;
            _voter.voteCandidate_id = 0;
        } else {
            _voter.hasVoted = true;
            _voter.voteCandidate_id = _candidateId;
            candidate_details[_candidateId].votes++;
        }
    }

    function voter_list() public view returns (voter[] memory) {
        voter[] memory array_voter = new voter[](nextVoter_id - 1);
        for (uint i = 1; i < nextVoter_id; i++) {
            array_voter[i - 1] = voter_details[i];
        }
        return array_voter;
    }
}

struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}

contract ProposalMaster {
    _proposalId: Int as uint32 = 0;

    // deploy
    receive() { }

    receive(msg: DeployNewProposal) {
        if(now() <= msg.votingEndingAt){
            deploy(DeployParameters{
                init: initOf Proposal(ProposalInit{master: myAddress(), proposalId: self._proposalId}),
                value: ton("0.01"),
                body: msg.toCell(), // not necessary, can be omitted
            });
            self._proposalId += 1;
        }else{
            throw(257);
        }
    
    }

    get fun nextProposalId(): Int {
        return self._proposalId;
    }
}

// ==============================================================================

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
    master: Address;
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    _proposalState: ProposalState;
    _voter: map<Address, Bool>;

    init(data: ProposalInit) {
        if(sender() != data.master){
            throw(2025);
        }
        self._proposalState = ProposalState { yesCount: 0, noCount: 0, proposalId: data.proposalId, master: data.master, votingEndingAt:0 };
    }

    // deploy
    // receive() {}

    receive(msg: Vote) {
        if(self._proposalState.noCount + self._proposalState.yesCount >= 100 || self._proposalState.votingEndingAt < now() || self._voter.get(sender()) == true ){
            throw(257);
        }
        if (msg.value == true) {
            self._proposalState.yesCount += 1;
        }else {
            self._proposalState.noCount += 1;
        }
        self._voter.set(sender(), true);
    }
    receive(msg: DeployNewProposal) {
        if (sender() != self._proposalState.master){
            throw(2025);
        }
        self._proposalState.votingEndingAt = msg.votingEndingAt;
    }

    get fun proposalState(): ProposalState {
        return self._proposalState;
    }
}
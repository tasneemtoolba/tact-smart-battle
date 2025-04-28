struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}
message DeployNewProposalWithSender {
    votingEndingAt: Int as uint32;
    sender: Address;
}


contract ProposalMaster {
    _proposalId: Int as uint32 = 0;
    const _tonValue: Int= ton("0.01");
    // deploy
    receive() {

        if(myBalance() > self._tonValue){
            nativeReserve(self._tonValue, ReserveAtMost);
            message(MessageParameters{
            to: sender(),
            mode: SendRemainingBalance,
            value:0
        });
     }
    }

    receive(msg: DeployNewProposal) {
        if(now() <= msg.votingEndingAt){
            deploy(DeployParameters{
                init: initOf Proposal(ProposalInit{master: myAddress(), proposalId: self._proposalId}),
                value:0,
                mode:64,
                body: DeployNewProposalWithSender{sender: sender(),votingEndingAt: msg.votingEndingAt}.toCell(),
            });
            self._proposalId += 1;
            // cashback(sender());
        }else{
            cashback(sender());
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
    receive() {
            }

    receive(msg: Vote) {
        if(self._proposalState.noCount + self._proposalState.yesCount >= 100 || self._proposalState.votingEndingAt < now() || self._voter.get(sender()) == true ){
            cashback(sender());
            throw(257);
        }
        if (msg.value == true) {
            self._proposalState.yesCount += 1;
        }else {
            self._proposalState.noCount += 1;
        }
        self._voter.set(sender(), true);
        cashback(sender());
    }
    receive(msg: DeployNewProposalWithSender) {
        if (sender() != self._proposalState.master){
            cashback(msg.sender);
            throw(2025);
        }
        self._proposalState.votingEndingAt = msg.votingEndingAt;
        cashback(msg.sender);
    }

    get fun proposalState(): ProposalState {
        return self._proposalState;
    }
}
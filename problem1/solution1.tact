message Vote {
    value: Bool;
}
 
struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
}
 
struct Init {
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}
 
contract Proposal {
    _proposalState: ProposalState;
    _votingEndingAt: Int as uint32;
    _voter: map<Address, Bool>;
 
    init(data: Init) {
        self._proposalState = ProposalState { yesCount: 0, noCount: 0 };
        self._votingEndingAt = data.votingEndingAt;
    }
 
    // deploy
    receive() {}
 
    receive(msg: Vote) {
        if(self._proposalState.noCount + self._proposalState.yesCount >= 100 || self._votingEndingAt < now() || self._voter.get(sender()) == true ){
            cashback(sender());
            throw(2025);
        }
        if (msg.value == true) {
            self._proposalState.yesCount += 1;
        }else{
            self._proposalState.noCount += 1;
        }
        self._voter.set(sender(), true);
        cashback(sender());
    }
 
    get fun proposalState(): ProposalState {
        return self._proposalState;
    }
}
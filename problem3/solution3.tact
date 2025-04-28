message Vote {
    value: Bool;
}

fun addressToU32(addr: Address): Int {
    return addr.asSlice().hash() % 4294967296;
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
    _voter: map<Int as uint32, Bool>;

    init(data: Init) {
        self._proposalState = ProposalState { yesCount: 0, noCount: 0 };
        self._votingEndingAt = data.votingEndingAt;
    }

    // deploy
    receive() {}

    receive(msg: Vote) {
        let senderr = addressToU32(sender());
        if (self._votingEndingAt < now() || self._voter.get(senderr) == true) {
            throw(257);
        }
        if (msg.value == true) {
            self._proposalState.yesCount += 1;
        } else {
            self._proposalState.noCount += 1;
        }
        self._voter.set(senderr, true);
    }

    get fun proposalState(): ProposalState {
        return self._proposalState;
    }
}
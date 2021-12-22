%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import (HashBuiltin, SignatureBuiltin)
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

from dontpanicdao.contracts.lib.ownable import (Init_Ownable, Get_Owner, Only_Owner, Transfer_Ownable_Ownership)

# TODO: consider having this contract own the NTNFT
####################
# NAIVE ROLES
####################
# TODO: 
# - DAO as account
# - Contact inherit edit/update governance rules

const READ = 0 # STUDENT
const WRITE = 1 # EDUCATOR
const VOTE = 2 # GODMODE

struct Contributor:
    member votes : felt
    member attestations : felt
    member role_id : felt
    member dob : felt # unix epoch, cairo internal maybe better?
end

struct VoteRecord:
    member vote : felt
    member vote_id : felt
    member r : felt
    member s : felt
end

struct Vote:
    member proposal_id : felt
    member n_yes_votes : felt
    member n_no_votes : felt
    member revertable : felt
    member bake_time : felt
    member min_threshold : felt
    member finalization_timestamp : felt
    member access_level : felt
end

struct Proposal:
    member name : felt
    member is_draft : felt
    member vote_id : felt
end

####################
# STORAGE VARIABLES
####################

@storage_var
func votes(vote_id: felt) -> (vote: Vote):
end

####################
# CONSTRUCTOR
####################
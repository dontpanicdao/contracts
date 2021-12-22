%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.hash import hash2
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le, assert_nn
from starkware.starknet.common.syscalls import (call_contract, get_caller_address, get_tx_signature, get_contract_address)

####################
# STORAGE VARIABLES
####################

@storage_var
func _current_nonce() -> (res: felt):
end

@storage_var
func _signer() -> (res: felt):
end

@storage_var
func _guardian() -> (res: felt):
end

####################
# CONSTRUCTOR
####################

@constructor
func constructor{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(signer: felt, guardian: felt):
    assert_not_zero(signer)
    
    _signer.write(signer)
    _guardian.write(guardian)
    
    return ()
end

####################
# INTERNAL FUNCTIONS
####################

# Account Nonce is a transaction counter in each account 
# - send a tx once it's mined your account increments the value by one
# - nonce keeps track of  how many tx the sender has overtime
# - nonce is teh tx counter of the sending addr no rx
# - allows us to send txs in order
# - different miners recieve your tx so how do they know which must go first
# - THE TRANSACTION IS NOT UNIQUE WITHOUT THE NONCE
# - makes every transaction unique
# - even though I signed the transaction, it can't be played again as the nonces increment would change the signature

# only outgoing txs will increment your nonce
func validate_and_bump_nonce{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(msg_nonce: felt) -> ():
    let (curr_nonce) = _current_nonce.read()
    assert curr_nonce = msg_nonce
    
    _current_nonce.write(curr_nonce + 1)
    return ()
end

####################
# EXTERNAL FUNCTIONS
####################

@external
func execute{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(to: felt, selector: felt, calldata_len: felt, calldata: felt*, nonce: felt):
    alloc_locals
    validate_and_bump_nonce(nonce)


end


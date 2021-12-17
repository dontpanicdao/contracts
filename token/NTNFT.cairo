########################################
# NTNFT: 
# Non-Transferable Non-Fungible Token
# Implementation of the ERC721 Standard 
# without the ability to transfer the 
# token to another address
########################################
%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import (assert_nn_le, assert_not_zero, assert_not_equal, assert_nn)

from dontpanicdao.contracts.lib.ownable import (Init_Ownable, Get_Owner, Only_Owner, Transfer_Ownable_Ownership)
from dontpanicdao.contracts.lib.counter import (Init_Counter, Increment, Decrement, Get_Count)

####################
# DUMMY BURN ALPHA ADDR
####################
const DUMMY_BURN_ADDR = 767419284764030882051110048744330164366892239954538492850503316116845804253

struct TokenMeta:
    member owner : felt
    member name : felt
end

struct BaseURI:
    member protocol : felt
    member domain_1 : felt
    member domain_2 : felt
    member path : felt
end

####################
# STORAGE VARIABLES
####################

@storage_var
func base_uri_store() -> (base_uri: BaseURI):
end

# mapping from a token id to a TokenMeta instance
@storage_var
func tokens(token_id: felt) -> (meta: TokenMeta):
end

@storage_var
func balances(owner: felt) -> (res: felt):
end

@storage_var
func name_store() -> (res: felt):
end

@storage_var
func symbol_store() -> (res: felt):
end

####################
# CONSTRUCTOR
####################

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(name: felt, symbol: felt, base_uri: BaseURI):
    assert_not_zero(name)
    assert_not_zero(symbol)
    
    let (caller) = get_caller_address()
    Init_Ownable(caller)
    Init_Counter()

    name_store.write(name)
    symbol_store.write(symbol)
    base_uri_store.write(base_uri)

    return()
end

####################
# GETTER FUNCTIONS
####################

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (res: felt):
    let (res) = balances.read(owner)
    return (res)
end

@view
func tokenMeta{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_id: felt) -> (res: felt):
    let (token: TokenMeta) = tokens.read(token_id)
    return (token)
end

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt):
    let (supply) = Get_Count()
    return (supply)
end

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_id: felt) -> (res: felt):
    let (token_meta: TokenMeta) = tokens.read(token_id=token_id)
    return (token_meta.owner)
end

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt):
    let (name) = name_store.read()
    return (name)
end

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt):
    let (symbol) = symbol_store.read()
    return (symbol)
end

@view
func baseURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (base_uri: BaseURI):
    let (base_uri: BaseURI) = base_uri_store.read()
    return (base_uri)
end

@view
func contractOwner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt):
    let (owner) = Get_Owner()
    return (owner)
end

####################
# INTERNAL FUNCTIONS
####################

func _transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(sender: felt, recipient: felt, token_id: felt):
    alloc_locals
    assert_not_zero(recipient)

    let (local token_meta: TokenMeta) = tokens.read(token_id)
    assert_not_equal(token_meta.owner, recipient)
    tokens.write(token_id, TokenMeta(recipient, token_meta.name))

    let (local sender_balance) = balances.read(owner=sender)
    assert_nn(sender_balance - 1)
    balances.write(sender, sender_balance - 1)

    let (recipient_balance) = balances.read(owner=recipient)
    balances.write(recipient, recipient_balance + 1)

    return ()
end

####################
# EXTERNAL FUNCTIONS
####################

@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_id: felt, token_owner: felt, name: felt) -> ():
    Only_Owner()

    assert_not_zero(token_id)
    assert_not_zero(token_owner)
    assert_not_zero(name)

    let (token_exists) = ownerOf(token_id)
    assert (token_exists) = 0

    tokens.write(token_id, TokenMeta(owner=token_owner, name=name))

    let (balance) = balances.read(token_owner)
    balances.write(token_owner, balance + 1)

    Increment()

    return ()
end

@external
func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_id: felt) -> ():
    alloc_locals
    let (local caller) = get_caller_address()
    let (local token_meta: TokenMeta) = tokens.read(token_id)

    assert (caller) = token_meta.owner

    _transfer(caller, DUMMY_BURN_ADDR, token_id)

    Decrement()

    return ()
end

@external
func transferContractOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_owner: felt) -> (new_owner: felt):
    Only_Owner()

    let (new_owner) = Transfer_Ownable_Ownership(new_owner)

    return (new_owner)
end

# TEST FUNCTIONS. REMOVE FOR MAINNET

@external
func transferTokenTest{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(sender: felt, recipient: felt, token_id: felt):
    Only_Owner()

    _transfer(sender, recipient, token_id)

    return ()
end

@external
func updateURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_uri: BaseURI):
    Only_Owner()

    let (prev_uri: BaseURI) = base_uri_store.read()
    base_uri_store.write(new_uri)

    return ()
end
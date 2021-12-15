%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import (HashBuiltin, SignatureBuiltin)
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt)

####################
# STORAGE VARIABLES
####################

@storage_var
func balances(account: felt) -> (res: Uint256):
end

@storage_var
func allowances(owner: felt, spender: felt) -> (res: Uint256):
end

@storage_var
func total_supply() -> (res: Uint256):
end

@storage_var
func decimals_store() -> (res: felt):
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
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(recipient: felt, amount: Uint256, name: felt, symbol: felt):
    decimals_store.write(18)
    name_store.write(name)
    symbol_store.write(symbol)
    _mint(recipient, amount)
    return ()
end

####################
# GETTER FUNCTIONS
####################

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: Uint256):
    let (res: Uint256) = total_supply.read()
    return (res)
end

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt):
    let (res) = decimals_store.read()
    return (res)
end

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (res: Uint256):
    let (res: Uint256) = balances.read(account=account)
    return (res)
end

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt, spender: felt) -> (res: Uint256):
    let (res: Uint256) = allowances.read(owner=owner, spender=spender)
    return (res)
end

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt):
    let (res) = name_store.read()
    return (res)
end

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt):
    let (res) = symbol_store.read()
    return (res)
end

####################
# INTERNAL FUNCTIONS
####################

func _mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(recipient: felt, amount: Uint256):
    alloc_locals
    assert_not_zero(recipient)

    let (balance: Uint256) = balances.read(account=recipient)

    let (new_balance, _: Uint256) = uint256_add(balance, amount)
    balances.write(recipient, new_balance)

    let (local supply: Uint256) = total_supply.read()
    let (local new_supply: Uint256, is_overflow) = uint256_add(supply, amount)
    assert (is_overflow) = 0

    total_supply.write(new_supply)
    return ()
end

func _transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(sender: felt, recipient: felt, amount: Uint256):
    alloc_locals
    assert_not_zero(sender)
    assert_not_zero(recipient)

    let (local sender_balance: Uint256) = balances.read(account=sender)

    let (enough_balance) = uint256_le(amount, sender_balance)
    assert_not_zero(enough_balance)

    let (new_sender_balance: Uint256) = uint256_sub(sender_balance, amount)
    balances.write(sender, new_sender_balance)

    let (recipient_balance: Uint256) = balances.read(account=recipient)
    let (new_recipient_balance, _: Uint256) = uint256_add(recipient_balance, amount)
    balances.write(recipient, new_recipient_balance)
    
    return()
end

func _approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(caller: felt, spender: felt, amount: Uint256):
    assert_not_zero(caller)
    assert_not_zero(spender)
    allowances.write(caller, spender, amount)

    return ()
end

####################
# EXTERNAL FUNCTIONS
####################

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(recipient: felt, amount: Uint256):
    alloc_locals
    let (sender) = get_caller_address()
    _transfer(sender, recipient, amount)
    return ()
end

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(sender: felt, recipient: felt, amount: Uint256):
    alloc_locals
    let (local caller) = get_caller_address()
    let (local caller_allowance: Uint256) = allowances.read(owner=sender, spender=caller)

    let (enough_balance) = uint256_le(amount, caller_allowance)
    assert_not_zero(enough_balance)

    _transfer(sender, recipient, amount)

    let (new_allowance: Uint256) = uint256_sub(caller_allowance, amount)
    allowances.write(sender, caller, new_allowance)
    return ()
end

@external
func increaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(spender: felt, added_value: Uint256):
    alloc_locals
    let (local caller) = get_caller_address()
    let (local current_allowance: Uint256) = allowances.read(caller, spender)

    let (local new_allowance: Uint256, is_overflow) = uint256_add(current_allowance, added_value)
    assert (is_overflow) = 0

    _approve(caller, spender, new_allowance)
    return ()
end

@external
func decreaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(spender: felt, subtracted_value: Uint256):
    alloc_locals
    let (local caller) = get_caller_address()
    let (local current_allowance: Uint256) = allowances.read(owner=caller, spender=spender)
    let (local new_allowance: Uint256) = uint256_sub(current_allowance, subtracted_value)

    let (enough_allowance) = uint256_lt(new_allowance, current_allowance)
    assert_not_zero(enough_allowance)

    _approve(caller, spender, new_allowance)
    return ()
end
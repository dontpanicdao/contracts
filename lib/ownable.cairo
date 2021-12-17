%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

####################
# STORAGE VARIABLES
####################

@storage_var
func Owner_Store() -> (owner: felt):
end

####################
# CONSTRUCTOR HELPER
####################

func Init_Ownable{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt):
    Owner_Store.write(owner)

    return ()
end

####################
# GETTERS
####################

func Get_Owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt):
    let (owner) = Owner_Store.read()

    return (owner)
end

####################
# LIBS
####################

func Only_Owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    let (owner) = Owner_Store.read()
    let (caller) = get_caller_address()
    assert owner = caller

    return ()
end

func Transfer_Ownable_Ownership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_owner: felt) -> (owner: felt):
    Owner_Store.write(new_owner)

    let (owner) = Owner_Store.read()

    return (owner)
end
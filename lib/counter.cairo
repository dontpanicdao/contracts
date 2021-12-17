%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

####################
# STORAGE VARIABLES
####################

@storage_var
func Counter() -> (count: felt):
end

####################
# CONSTRUCTOR HELPER
####################

func Init_Counter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    Counter.write(0)

    return ()
end

####################
# GETTERS
####################

func Get_Count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt):
    let (count) = Counter.read()
    return (count)
end

####################
# LIBS
####################

func Increment{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt):
    let (count) = Counter.read()
    Counter.write(count + 1)

    let (new_count) = Counter.read()

    return (count=new_count)
end

func Decrement{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt):
    let (count) = Counter.read()
    assert_not_zero(count)
    
    Counter.write(count - 1)

    let (new_count) = Counter.read()

    return (count=new_count)
end

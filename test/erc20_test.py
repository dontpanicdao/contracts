import os
import asyncio
import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.compiler.compile import compile_starknet_files

user = 0x41d8b1b848c1c90b438dbeef0dc89367b9d45ea0f17ab73eaf5ab2005b95712

CONTRACT_FILE = os.path.join(os.path.dirname(__file__), "../token/ERC20.cairo")

def uint(a):
    return(a, 0)

def str_to_felt(text):
    b_text = bytes(text, 'UTF-8')
    return int.from_bytes(b_text, "big")

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()

@pytest.fixture(scope='module')
async def get_starknet():
    starknet = await Starknet.empty()
    return starknet

@pytest.mark.asyncio
async def test_erc20(get_starknet):
    supply = uint(42000000000000000000000000000)
    name = str_to_felt('TmpDontPanic')
    sym = str_to_felt('TMPTWL')
    constructor_calldata=[
        user,
        *supply,
        name,
        sym
    ]

    starknet = get_starknet

    contract_definition = compile_starknet_files([CONTRACT_FILE], debug_info=True)
    deployed_contract = await starknet.deploy(contract_def=contract_definition, constructor_calldata=constructor_calldata)
    print(deployed_contract)


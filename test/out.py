user = 0x41d8b1b848c1c90b438dbeef0dc89367b9d45ea0f17ab73eaf5ab2005b95712

def uint(a):
    return(a, 0)

def str_to_felt(text):
    b_text = bytes(text, 'UTF-8')
    return int.from_bytes(b_text, "big")

supply = uint(42000000000000000000000000000000)
name = str_to_felt('TmpDontPanic')
sym = str_to_felt('TMPTWL')

print(user)
print(*supply)
print(name)
print(sym)
# Test Deployment for DPD NTNFT or "Subject Certs"

## IPFS Formatting
baseURI: ipfs://<DIRECTORY CID>/
tokenURI: <TOKEN CID>?filename=<CERT FILE NAME WITH EXTENSION>
exampleTokenURI: QmNtaC5ksPdAWSS17kFmnRHs9JkMCGuiyCLmTZD2cDZb51?filename=starkcert.json
TestCID: QmNtaC5ksPdAWSS17kFmnRHs9JkMCGuiyCLmTZD2cDZb51
- mint(token_uri="IPFS CID", name="FILE NAME")

## NOTES: 
- How will IERC721Reciever apply to starknet contracts?
- cleaning/checking addresses
- Why is get_caller_address not working?


## Deploy Command
```
starknet deploy --contract NTNFT_compiled.json --inputs 21179693039756148717650198863 \
4476996 29678457876786991 \
173823244441745514270219188361220711293249207074934577989385734924738847852 \
12572664705729300614974630008436715085618022584112155082864771689829 0
Deploy transaction was sent.
Contract address: 0x0437473244b4eac103bb7d03519686c86e1871116e110ec81ed615ec6fae50b2
Transaction hash: 0x495f36924b6f60c9c5e98aaadfc14c55c9750a72bca5898084bbb9c814172f4
```
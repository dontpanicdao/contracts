# Don't Panic DAO Starknet Contracts

### set up local alpha environment
https://www.cairo-lang.org/docs/quickstart.html

```
$ python3.9 -m venv ${HOME}/cairo_venv; source ${HOME}/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha
```

### test
```
$ pytest test/erc20_test.py
```
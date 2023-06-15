**Deploy to local fork**

```
forge create --rpc-url http://0.0.0.0:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 src/BalancerViewHelpers.sol:BalancerViewHelpers --constructor-args "0xBA12222222228d8Ba445958a75a0704d566BF2C8"
```

**Deploy with CREATE2 factory**

```
forge script script/DeterministicDeploy.s.sol:DeterministicDeploy --rpc-url http://0.0.0.0:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv
```

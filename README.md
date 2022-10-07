# Crowd Funding Smart Contract Using Factory

This is sample project the let you create a new crowd funding project using factory pattern. Using `CrowdSourcingFactory` one can implement the `CrowdFundingContract` by cloning it and deploying a fresh new contract that allow you to create 3 milestone and collect donation from fund seeders. 

It also allow to cast vote on milestone and campaign owner can only withdraw funds if the milestone passes, which require 2/3 of affirmative votes of the total votes casted.
---

## Run these commands

### To install all the dependencies

```shell
yarn install
```
### Compile code
```shell
yarn hardhat compile
```
### Running Tests
```shell
yarn hardhat test
```
### Running localhost hardhat blockchain network
```shell
yarn hardhat node
```
### Deploying
```shell
yarn hardhat run ./scripts/deploy.js
```


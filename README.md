# Simple RockPaperScissors Project

This project demonstrates a basic Smart Contract Game use case. It comes with a contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

![RockPaperScissors Game](./assets/image.png)

## Prerequisites

Ensure that Hardhat is installed on your system. You can install it using the following command:

```shell
npm install --save-dev hardhat
```

Next install node modules
```
npm i
```

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/RockPaperScissors.ts
```

// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";



const RockPaperScissorsModule = buildModule("RockPaperScissorsModule", (m) => {


  const rockPaperScissors = m.contract("RockPaperScissors", ["0xb9cc137fe7bc6a7b9813633d9cb1969bb79973f8316735246ad707ad0322a51d"], {
    value: 1n,
  });

  return { lock: rockPaperScissors };
});

export default RockPaperScissorsModule;

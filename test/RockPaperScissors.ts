import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

enum Choice { Pending = 0, Rock=1, Paper=2, Scissors=3 }

describe("RockPaperScissors", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployRockPaperScissorsFixture() {


    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const RockPaperScissors = await hre.ethers.getContractFactory("RockPaperScissors");

    // bytes of "password" and Choice.Rock
    const rockPaperScissors = await RockPaperScissors.deploy(
      "0xb9cc137fe7bc6a7b9813633d9cb1969bb79973f8316735246ad707ad0322a51d",
      { value: 1}
    );

    return { rockPaperScissors, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set right state", async function () {
      const { rockPaperScissors, owner, otherAccount } = await loadFixture(deployRockPaperScissorsFixture);

      expect((await rockPaperScissors.getGame()).state).to.equal(0);
      expect((await rockPaperScissors.getGame()).player1).to.equal(owner.address);
    });

    it("Should play and finish game", async function () {
      const { rockPaperScissors, owner, otherAccount }  = await loadFixture(deployRockPaperScissorsFixture);

      const playerOneConnection = await rockPaperScissors.connect(owner)
      const playerTwoConnection = await rockPaperScissors.connect(otherAccount)
      const _player2Hash = await playerTwoConnection.createHash("salt", Choice.Paper); 
      await playerTwoConnection.joinGame(_player2Hash, { value: 1 });
      await playerOneConnection.revealChoice(1, 'password');
      await playerTwoConnection.revealChoice(2, 'salt');

      const winnerTx = await playerOneConnection.revealWinner();



      expect((await rockPaperScissors.getGame()).state).to.equal(4);
      expect((await rockPaperScissors.getGame()).winner).to.equal(otherAccount.address);
    });


    //   const { lock, lockedAmount } = await loadFixture(
    //     deployRockPaperScissorsFixture
    //   );

    //   expect(await hre.ethers.provider.getBalance(lock.target)).to.equal(
    //     lockedAmount
    //   );
    // });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = await time.latest();
    //   const Lock = await hre.ethers.getContractFactory("Lock");
    //   await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
    //     "Unlock time should be in the future"
    //   );
    // });
  });


});

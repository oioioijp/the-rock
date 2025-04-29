// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract RockPaperScissors {
    enum Choice { Pending, Rock, Paper, Scissors }
    enum GameState { PlayerOneGone, PlayerTwoGone, OnePlayerRevealed, BothPlayersRevealed, Finished }



    event PlayerTurnTaken(address indexed player, GameState state);
    event PlayerTurnRevealed(address indexed player, GameState state, Choice choice);
    event GameFinished(address indexed winner, uint256 prize);



    constructor(bytes32 _player1Hash) payable {
        require(msg.value > 0, "Entry fee must be greater than 0");
        require(_player1Hash != bytes32(0), "Player 1 hash must not be empty");


        game = Game({
            player1: msg.sender,
            player2: address(0),
            choice1: Choice.Pending,
            choice2: Choice.Pending,
            player1Hash: _player1Hash,
            player2Hash: bytes32(0),
            entryFee: msg.value,
            state: GameState.PlayerOneGone,
            winner: address(0)

        });

        emit PlayerTurnTaken(msg.sender, game.state);
    }

    struct Game {
        address player1;
        address player2;
        Choice choice1;
        Choice choice2;
        bytes32 player1Hash;
        bytes32 player2Hash;
        uint256 entryFee;
        GameState state;
        address winner;
    }

    Game public game;


    function joinGame(bytes32 _player2Hash) external payable {
        require(game.state == GameState.PlayerOneGone, "Game is not in the correct state");
        require(msg.sender != game.player1, "Player 1 cannot join again");
        require(game.player2 == address(0), "Player 2 has already joined");
        require(msg.value == game.entryFee, "Incorrect entry fee");
        game.player2 = msg.sender;
        game.player2Hash = _player2Hash;
        game.state = GameState.PlayerTwoGone;
        emit PlayerTurnTaken(msg.sender, game.state);
    }

    function revealChoice(Choice _choice, string memory _secret) external {
        require(game.state == GameState.PlayerTwoGone || game.state == GameState.OnePlayerRevealed, "Game is not in the correct state");
        require(msg.sender == game.player1 || msg.sender == game.player2, "Only players can reveal");
        require(_choice != Choice.Pending, "Invalid choice");

        if (msg.sender == game.player1) {
            require(game.choice1 == Choice.Pending, "Player 1 has already revealed their choice");
            require(keccak256(abi.encodePacked(_secret, _choice)) == game.player1Hash, "Invalid hash for Player 1");
            game.choice1 = _choice;

            if (game.state == GameState.PlayerTwoGone) {
                game.state = GameState.OnePlayerRevealed;
            } else {
                game.state = GameState.BothPlayersRevealed;
            }

        } else {
            require(game.choice2 == Choice.Pending, "Player 2 has already revealed their choice");
            require(keccak256(abi.encodePacked(_secret, _choice)) == game.player2Hash, "Invalid hash for Player 2");
            game.choice2 = _choice;
                 if (game.state == GameState.PlayerTwoGone) {
                game.state = GameState.OnePlayerRevealed;
            } else {
                game.state = GameState.BothPlayersRevealed;
            }
        }

        emit PlayerTurnRevealed(msg.sender, game.state, _choice);
    }

    

    function revealWinner() external  {
        require(game.state == GameState.BothPlayersRevealed, "Game is not in the correct state");
        require(game.choice1 != Choice.Pending && game.choice2 != Choice.Pending, "Both players must make a choice");

        address winner;
        if (game.choice1 == game.choice2) {
            // It's a draw
            payable(game.player1).transfer(game.entryFee);
            payable(game.player2).transfer(game.entryFee);
          emit GameFinished(address(0), game.entryFee);
          winner = address(0);
        } else if (
            (game.choice1 == Choice.Rock && game.choice2 == Choice.Scissors) ||
            (game.choice1 == Choice.Scissors && game.choice2 == Choice.Paper) ||
            (game.choice1 == Choice.Paper && game.choice2 == Choice.Rock)
        ) {
            // Player 1 wins
            payable(game.player1).transfer(2 * game.entryFee);
            emit GameFinished(game.player1, game.entryFee);
            winner = address(game.player1);
        } else {
            // Player 2 wins
            payable(game.player2).transfer(2 * game.entryFee);
            emit GameFinished(game.player2, game.entryFee);
             winner = address(game.player2);
        }

        game.state = GameState.Finished;
        game.winner = winner;

    }

    function getGame() external view returns (Game memory) {
        return game;
    }

    function createHash(string memory _secret, Choice _choice) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_secret, _choice));
    }
    function verifyHash(string memory _secret, Choice _choice, bytes32 _hash) external pure returns (bool) {
        require(uint8(_choice) >= uint8(Choice.Rock) && uint8(_choice) <= uint8(Choice.Scissors), "Invalid choice");
        return keccak256(abi.encodePacked(_secret, _choice)) == _hash;
    }


}
 
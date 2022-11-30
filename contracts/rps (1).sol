// SPDX-License-Identifier: UNLICENSED
// Соколова Диана БПИ202
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract RSPGame {

    enum Action {
        None,
        Rock,
        Scissors,
        Paper
    }

    enum State {
        WaitingPlayers,
        WaitingPlayersActions,
        WaitingProves,
        Complited,
        FinishGame
    }

    struct Game {
        address  player1;
        address  player2;
        State  current_state;
        Action  player1_action;
        Action  player2_action;
        address player_winner;
        bytes32 player1_hash;
        bytes32 player2_hash;
    }

    Game private current_game;
    event ChangeState(State);
    event GameFinished(Game);

    constructor() {
        newGame();
    }

    function newGame() public {
        current_game = Game(address(0x0),address(0x0),State.WaitingPlayers, Action.None,Action.None, address(0x0), 0x0, 0x0);
        emit ChangeState(current_game.current_state);
    }

    modifier isCorrectNewUserAddress() {
        require(
            msg.sender != current_game.player1 &&
                msg.sender != current_game.player2
        );
        _;
    }

    modifier isPlayer() {
        require(
            msg.sender != current_game.player1 ||
                msg.sender != current_game.player2
        );
        _;
    }

    function addPlayer() public isCorrectNewUserAddress returns (uint256) {
        require(current_game.current_state == State.WaitingPlayers); 
        if (current_game.player1 == address(0x0)) {
            current_game.player1 = address(msg.sender);
            return 1;
        }

        if (current_game.player2 == address(0x0)) {
            current_game.player2 = address(msg.sender);
            current_game.current_state = State.WaitingPlayersActions;
            emit ChangeState(current_game.current_state);
            return 2;
        }
        return 0;
    }

    function makeAction(bytes32 hash) public isPlayer returns (bool) {
        require(current_game.current_state == State.WaitingPlayersActions); 
        if (msg.sender == current_game.player1 
                        && current_game.player1_hash == 0x0) {
            current_game.player1_hash = hash;
        } else if (msg.sender == current_game.player2 
                        && current_game.player2_hash == 0x0) {
            current_game.player2_hash = hash;
        }

        if (current_game.player1_hash != 0x0
                        && current_game.player2_hash != 0x0) {
            current_game.current_state = State.WaitingProves;
            emit ChangeState(current_game.current_state);
            getResult();
            return true;
        }
        return false;
    }

    function proveAction(Action action, uint32 salt) public isPlayer returns (bool) {
        require(current_game.current_state == State.WaitingProves); 

        bytes32 hash = sha256(
            bytes.concat(
                bytes(Strings.toString(uint256(action))),
                bytes(Strings.toString(salt))
            )
        );

        if (msg.sender == current_game.player1 
                        && current_game.player1_action == Action.None 
                        && hash == current_game.player1_hash) {
            current_game.player1_action = action;
        } else if (msg.sender == current_game.player2 
                        &&current_game.player2_action == Action.None 
                        && hash == current_game.player2_hash) {
            current_game.player2_action = action;
        }

        if (current_game.player1_action != Action.None
                        && current_game.player2_action != Action.None) {
            current_game.current_state = State.Complited;
            emit ChangeState(current_game.current_state);
            getResult();
            return true;
        }
        return false;
    }

    function getResult() public isPlayer {
        require(current_game.current_state == State.Complited);
        require(current_game.player1_action!=Action.None && current_game.player2_action!=Action.None);
        if (current_game.player1_action == current_game.player2_action) {
                current_game.player_winner = address(0x0);
                emit GameFinished(current_game);
                return;
            }

        if (current_game.player1_action == Action.Paper) {
                if (current_game.player2_action == Action.Scissors) {
                    current_game.player_winner = current_game.player2;
                } else {
                    current_game.player_winner = current_game.player1;
                }
            } else if (current_game.player1_action == Action.Rock) {
                if (current_game.player2_action == Action.Paper) {
                    current_game.player_winner = current_game.player2;
                } else {
                    current_game.player_winner = current_game.player1;
                }
            } else {
                if (current_game.player2_action == Action.Rock) {
                    current_game.player_winner = current_game.player2;
                } else {
                    current_game.player_winner = current_game.player1;
                }
            }
            current_game.current_state = State.FinishGame;
            emit ChangeState(current_game.current_state);
            emit GameFinished(current_game);
        }
}

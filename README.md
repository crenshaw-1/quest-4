# Advanced Rock Paper Scissors Game on Aptos

This smart contract implements an advanced Rock Paper Scissors game on the Aptos blockchain. Players compete against a computer opponent in multiple rounds, with score tracking and an exciting High Stakes Mode for added thrill!

## Features

1. **Single Player vs Computer**: Play against a computer opponent with randomly generated moves.
2. **Multiple Rounds**: Play multiple rounds without restarting the game.
3. **Score Tracking**: Keep track of player and computer scores across multiple rounds.
4. **High Stakes Mode**: Bet APT tokens for a chance to multiply your winnings!
5. **Win Streak Multiplier**: Consecutive wins in High Stakes Mode increase your potential payout.
6. **Computer Advantage**: In High Stakes Mode, the computer has a slight edge, increasing the challenge.
7. **Game Treasury**: A secure system for handling bets and payouts.
8. **View Functions**: Easily retrieve game state, moves, scores, and betting information.

## Contract Details

- **Address**: `0x0691a514fb64df9cae0aecbbfd516178a175f5eb2b3064646048407f8f61c688`
- **Module**: `RockPaperScissors`

## How to Play

### Initial Setup
1. Initialize the game treasury (one-time setup):
   ```
   aptos move run --function-id <wallet-address>::RockPaperScissors::initialize_treasury
   ```

### Normal Mode
1. Start a new game:
   ```
   aptos move run --function-id <wallet-address>::RockPaperScissors::start_game
   ```
2. Set your move (1 for Rock, 2 for Paper, 3 for Scissors):
   ```
   aptos move run --function-id <wallet-address>::RockPaperScissors::set_player_move --args u8:1
   ```
3. Generate the computer's move:
   ```
   aptos move run --function-id <wallet-address>::RockPaperScissors::randomly_set_computer_move
   ```
4. Finalize the round:
   ```
   aptos move run --function-id <wallet-address>::RockPaperScissors::finalize_game_results
   ```
5. Repeat steps 2-4 for additional rounds.

### High Stakes Mode
1. Enter High Stakes Mode with your desired bet amount (in Octas, 1 APT = 100000000 Octas):
   ```
   aptos move run --function-id <wallet-address>::RockPaperScissors::enter_high_stakes_mode --args u64:100000000
   ```
2. Follow steps 2-4 from Normal Mode.
3. If you win, you'll receive your original stake multiplied by (win_streak + 1).
4. If you lose, you'll lose your stake.
5. Consecutive wins increase your win streak and potential payout!

## View Functions

Check the game state using these view functions:

- Get player's current move:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_player_move
  ```
- Get computer's current move:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_computer_move
  ```
- Get the result of the current round:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_game_results
  ```
- Get the player's total score:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_player_score
  ```
- Get the computer's total score:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_computer_score
  ```
- Get the total number of rounds played:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_rounds_played
  ```
- Get the current bet amount in High Stakes Mode:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_current_stake
  ```
- Check if the game is in Normal or High Stakes Mode:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_game_mode
  ```
- Get the current win streak in High Stakes Mode:
  ```
  aptos move view --function-id <wallet-address>::RockPaperScissors::get_win_streak
  ```

## High Stakes Mode Details

- In High Stakes Mode, the computer has a slight advantage, making it more challenging for the player.
- The win streak multiplier adds an exciting risk-reward element to the game.
- Players can potentially win big, but also risk losing their entire stake.
- The Game Treasury ensures secure handling of bets and payouts.

## Technical Implementation

- The contract uses the Aptos randomness module for fair computer move generation.
- A separate GameTreasury struct manages all bets and payouts, ensuring financial operations are secure and transparent.
- The computer's slight advantage in High Stakes Mode is implemented through a modified random number generation process.

## Future Enhancements

- Implement player vs player functionality with betting.
- Add leaderboards for highest win streaks and biggest wins.
- Develop a frontend interface for easier interaction and visualizing High Stakes Mode.

## Security Considerations

- The contract includes checks to prevent unauthorized access to critical functions.
- Betting limits could be implemented to promote responsible gambling.
- Regular audits are recommended to ensure the continued security and fairness of the game.

## Conclusion

This Advanced Rock Paper Scissors game demonstrates innovative use of blockchain technology for gaming. It combines classic gameplay with exciting betting mechanics, showcasing the potential for decentralized applications in the gaming industry.
address 0x0691a514fb64df9cae0aecbbfd516178a175f5eb2b3064646048407f8f61c688 {

module RockPaperScissors {
    use std::signer;
    use aptos_framework::randomness;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    const NORMAL_MODE: u8 = 1;
    const HIGH_STAKES_MODE: u8 = 2;

    const MAX_WINNINGS: u64 = 5_000_000; // Maximum winnings cap (5 APT)

    struct Game has key {
        player: address,
        player_move: u8,   
        computer_move: u8,
        result: u8,
        player_score: u64,
        computer_score: u64,
        rounds_played: u64,
        current_stake: u64,
        game_mode: u8,
        win_streak: u64,
    }

    struct GameTreasury has key {
        coins: coin::Coin<AptosCoin>,
    }

    public entry fun start_game(account: &signer) {
        let player = signer::address_of(account);

        let game = Game {
            player,
            player_move: 0,
            computer_move: 0,
            result: 0,
            player_score: 0,
            computer_score: 0,
            rounds_played: 0,
            current_stake: 0,
            game_mode: NORMAL_MODE,
            win_streak: 0,
        };

        move_to(account, game);
    }

    public entry fun set_player_move(account: &signer, player_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player_move = player_move;
    }

    public entry fun enter_high_stakes_mode(account: &signer, stake_amount: u64) acquires Game, GameTreasury {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        assert!(game.game_mode == NORMAL_MODE, 1);
        
        let account_addr = signer::address_of(account);
        assert!(coin::balance<AptosCoin>(account_addr) >= stake_amount, 2);
        
        let treasury = borrow_global_mut<GameTreasury>(@0x0dfcbff56c48e150cf9d73b19b625da39e90dcbe531429fdcd90d311b63413ed);
        let stake_coins = coin::withdraw<AptosCoin>(account, stake_amount);
        coin::merge(&mut treasury.coins, stake_coins);
        
        game.current_stake = stake_amount;
        game.game_mode = HIGH_STAKES_MODE;
    }

    #[randomness]
    entry fun randomly_set_computer_move(account: &signer) acquires Game {
        randomly_set_computer_move_internal(account);
    }

    public(friend) fun randomly_set_computer_move_internal(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        let random_number = if (game.game_mode == HIGH_STAKES_MODE) {
            randomness::u8_range(1, 5) 
        } else {
            randomness::u8_range(1, 4)
        };
        game.computer_move = if (random_number == 4) randomness::u8_range(1, 4) else random_number;
    }

    public entry fun finalize_game_results(account: &signer) acquires Game, GameTreasury {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.result = determine_winner(game.player_move, game.computer_move);
        game.rounds_played = game.rounds_played + 1;
        
        if (game.result == 2) {
            game.player_score = game.player_score + 1;
            game.win_streak = game.win_streak + 1;
            if (game.game_mode == HIGH_STAKES_MODE) {
                let winnings = game.current_stake * (game.win_streak + 1);
                let treasury = borrow_global_mut<GameTreasury>(@0x0dfcbff56c48e150cf9d73b19b625da39e90dcbe531429fdcd90d311b63413ed);
                
                let available_balance = coin::value(&treasury.coins);
                let payout_amount = if (winnings > MAX_WINNINGS) {
                    MAX_WINNINGS
                } else if (winnings > available_balance) {
                    available_balance
                } else {
                    winnings
                };

                let payout = coin::extract(&mut treasury.coins, payout_amount);
                coin::deposit(game.player, payout);
            }
        } else {
            if (game.result == 3) {
                game.computer_score = game.computer_score + 1;
            };
            game.win_streak = 0;
        };

        if (game.game_mode == HIGH_STAKES_MODE) {
            game.game_mode = NORMAL_MODE;
            game.current_stake = 0;
        };
    }

    fun determine_winner(player_move: u8, computer_move: u8): u8 {
        if (player_move == ROCK && computer_move == SCISSORS) {
            2 // player wins
        } else if (player_move == PAPER && computer_move == ROCK) {
            2 // player wins
        } else if (player_move == SCISSORS && computer_move == PAPER) {
            2 // player wins
        } else if (player_move == computer_move) {
            1 // draw
        } else {
            3 // computer loses
        }
    }

    public entry fun initialize_treasury(account: &signer) {
        let account_addr = signer::address_of(account);
        assert!(account_addr == @0x0dfcbff56c48e150cf9d73b19b625da39e90dcbe531429fdcd90d311b63413ed, 3);
        if (!exists<GameTreasury>(account_addr)) {
            let initial_funding = 5_000_000;
            let coins = coin::withdraw<AptosCoin>(account, initial_funding);
            move_to(account, GameTreasury { coins });
        }
    }

    #[view]
    public fun get_player_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player_move
    }

    #[view]
    public fun get_computer_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).computer_move
    }

    #[view]
    public fun get_game_results(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).result
    }

    #[view]
    public fun get_player_score(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).player_score
    }

    #[view]
    public fun get_computer_score(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).computer_score
    }

    #[view]
    public fun get_rounds_played(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).rounds_played
    }

    #[view]
    public fun get_current_stake(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).current_stake
    }

    #[view]
    public fun get_game_mode(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).game_mode
    }

    #[view]
    public fun get_win_streak(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).win_streak
    }
}
}

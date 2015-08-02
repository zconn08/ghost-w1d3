require 'set'
require 'byebug'
require_relative 'player'

class Game
  def initialize(*players)
    @players = players.map { |name| Player.new(name) }
    @num_players = @players.length
    @current_turn = 0
    @fragment =  ""
    @dictionary = Set.new File.readlines("ghost-dictionary.txt").map(&:chomp)
    @losses = Hash.new(0)
  end

  def current_player
    @players[@current_turn]
  end

  def previous_player
    @players[@current_turn - 1]
  end

  def run
    until @num_players == 1
      until loser?
        play_round
        display_standings
      end
      remove_loser
    end
    puts "Congratulations #{@players[0].name}! You won the game!"
  end

  def play_round
    until losing_play?
      take_turn(current_player)
      next_player!
    end
    puts "#{previous_player.name} made the word #{@fragment} and lost this round!"
    @losses[previous_player] += 1
    @fragment = ""
  end

  def next_player!
    @current_turn < (@num_players - 1) ? @current_turn += 1 : @current_turn = 0
  end

  def take_turn(player)
    initial_guess = player.guess
    until valid_play?(initial_guess)
      player.alert_invalid_guess
      initial_guess = player.guess
    end
    @fragment << initial_guess
    puts "Current word is #{@fragment}"
  end

  def valid_play?(character)
    potential_frag = @fragment + character
    ('a'..'z').include?(character) && set_check?(potential_frag)
  end

  def set_check?(frag)
    @dictionary.any? { |word| word.start_with?(frag) }
  end

  def losing_play?
    @dictionary.any? {|word| word == @fragment }
  end

  def record(player)
    num_losses = @losses[player]
    "GHOST"[0...num_losses]
  end

  def loser?
    @players.any? { |player| record(player) == "GHOST" }
  end

  def display_standings
    @players.each { |player| puts "#{player.name}: #{record(player)}" }
  end

  def remove_loser
    puts "Goodbye #{previous_player.name}. Better luck next time!"
    @players.delete(previous_player)
    @num_players -= 1
  end
end

Game.new('Joe','Bob', "John").run

require 'set'
require 'byebug'
require_relative 'player'
require_relative 'ai_player'

class Game
  attr_reader :dictonary, :fragment

  def initialize(*players)
    @dictionary = Set.new File.readlines("ghost-dictionary.txt").map(&:chomp)
    @players = players.map { |name| Player.new(name) }
    @players << AiPlayer.new(@dictionary)
    @num_players = @players.length
    @current_turn = 0
    @fragment =  ""
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
    puts "#{previous_player.name} made the word '#{@fragment}' and lost this round!"
    puts "New round starts now!"
    @losses[previous_player] += 1
    @fragment = ""
  end

  def next_player!
    @current_turn < (@num_players - 1) ? @current_turn += 1 : @current_turn = 0
  end

  def take_turn(player)
    player.receive_fragment(@fragment)
    initial_guess = player.guess
    until valid_play?(initial_guess)
      player.alert_invalid_guess
      initial_guess = player.guess
    end
    unless @fragment.empty?
      initial_position = player.position
    end
    until valid_position?(initial_position, initial_guess)
      player.alert_invalid_position
      initial_position = player.position
    end
    @fragment << initial_guess if initial_position == "back"
    @fragment = initial_guess + @fragment if initial_position == "front" || @fragment.empty?
    puts "Current word is #{@fragment}"
  end

  def valid_play?(character)
    potential_frag = @fragment + character
    potential_frag_two = character + @fragment
    ('a'..'z').include?(character) && (set_check?(potential_frag) || set_check?(potential_frag_two))
  end

  def valid_position?(position, character)
    potential_frag = @fragment + character if position == "back"
    potential_frag = character + @fragment if position == "front"
    (position == "front" || position == "back") && set_check?(potential_frag) || @fragment.empty?
  end

  def set_check?(frag)
    front_fragments = ("a".."z").to_a.map { |letter| letter += @fragment}
    front_dictionary = []
    @dictionary.each do |word|
      front_fragments.each do |frag|
        front_dictionary << word if word.start_with?(frag)
      end
    end
    @dictionary.any? { |word| word.start_with?(frag) } || front_dictionary.uniq.join("").include?(frag)
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

Game.new('Joe','George').run

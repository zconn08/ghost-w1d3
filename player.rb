class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def guess
    puts "Enter a letter #{@name}!"
    gets.chomp.downcase
  end

  def position
    puts "Front or back?"
    gets.chomp.downcase
  end

  def alert_invalid_guess
    puts "Please select a valid character!"
  end

  def alert_invalid_position
    puts "Please select a valid position ('front' or 'back')"
  end

  def receive_fragment(fragment)
  end
end

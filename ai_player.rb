class AiPlayer
  attr_reader :name

  def initialize(dictionary)
    @name = "Computer"
    @fragment = ""
    @dictionary = dictionary
    @current_position = "back"
  end

  def guess
    back_guesses = valid_dictionary_subset_back.select do |word|
      word.length > (@fragment.length + 1)
    end
    front_guesses = valid_dictionary_subset_front.select do |word|
      word.length > (@fragment.length + 1)
    end

    if !front_guesses.empty?
      @current_position = "front"
      return front_guesses.sample[0]
    elsif !back_guesses.empty?
      @current_position = "back"
      return back_guesses.sample[@fragment.length]
    else
      if !(valid_dictionary_subset_back.empty?)
        @current_position = "back"
        return valid_dictionary_subset_back.sample[@fragment.length]
      elsif !(valid_dictionary_subset_front.empty?)
        @current_position = "front"
        return valid_dictionary_subset_front.sample[0]
      end
    end

  end

  def position
    @current_position
  end

  def alert_invalid_guess
  end

  def alert_invalid_position
  end

  def receive_fragment(fragment)
    @fragment = fragment
  end

  def valid_dictionary_subset_back
    @dictionary.select {|word| word.start_with?(@fragment)}
  end

  def valid_dictionary_subset_front
    front_fragments = ("a".."z").to_a.map { |letter| letter += @fragment}
    front_dictionary = []
    @dictionary.each do |word|
      front_fragments.each do |frag|
        front_dictionary << word if word.start_with?(frag)
      end
    end
    front_dictionary.uniq
  end

end

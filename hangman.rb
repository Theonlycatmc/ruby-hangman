class Wordlist
  def select_random_word
    @filtered_words[rand(@filtered_words.length)].downcase
  end

  def initialize
    dictionary = File.open('5desk.txt', 'r')
    @filtered_words = dictionary
                      .readlines(chomp: true)
                      .select { |word| word.length > 4 && word.length < 13 }
    dictionary.close
  end
end
class Game

  protected

  @@MAX_FAILURES = 5

  def restart
    @current_failures = 0
    @current_word = @wordlist.select_random_word
    @current_guesses = []
    @current_word_display = Array.new(@current_word.length, '_')
    @win = 0
    game_start
  end

  def initialize
    @wordlist = Wordlist.new
    restart
  end

  def show_stickman
    case @current_failures
    when 0
      puts '-------------'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    when 1
      puts '-------------'
      puts '   |       ||'
      puts '   O       ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    when 2
      puts '-------------'
      puts '   |       ||'
      puts '   O       ||'
      puts '   |       ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    when 3
      puts '-------------'
      puts '   |       ||'
      puts '   O       ||'
      puts '  /|       ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    when 4
      puts '-------------'
      puts '   |       ||'
      puts '   O       ||'
      puts '  /|\\      ||'
      puts '           ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    when 5
      puts '-------------'
      puts '   |       ||'
      puts '   O       ||'
      puts '  /|\\      ||'
      puts '  /        ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    when 6
      puts '-------------'
      puts '   |       ||'
      puts '   O       ||'
      puts '  /|\\      ||'
      puts '  / \\      ||'
      puts '           ||'
      puts '           ||'
      puts '_________ /  \\_'
      puts '|______________|'
    end
  end

  def show_status
    puts ''
    show_stickman
    puts @current_word_display.join(' ')
    puts "Your guesses: #{@current_guesses.join(' ')}"
  end

  def check_choice
    @current_guesses.push(@choice)
    if @current_word.split('').none? { |letter| letter == @choice }
      @current_failures += 1
      return
    end
    @current_word.split('').each_with_index { |letter, index| @current_word_display[index] = letter if letter == @choice }
  end

  def turn
    @choice = ''
    while @choice == ''
      show_status
      if @current_word_display == @current_word.split('')
        puts 'You Win!'
        @win = 1
        break
      end
      print 'Your guess: '
      @choice = gets.chomp
      if @choice.length != 1
        puts 'Your guess must only be one letter long.'
        redo
      elsif @current_guesses.any? { |guess| guess == @choice }
        puts 'You already guessed that!'
        redo
      elsif @choice =~ /[a-z]/
        check_choice
      else
        puts 'You guess must be a letter'
      end
      3.times { puts '' }
    end
  end

  def game_start
    while @win.zero?
      if @current_failures > @@MAX_FAILURES
        show_status
        puts 'You lost!'
        puts "The word was #{@current_word}"
        break
      end
      turn
    end
    puts ''
    restart_choice = ''
    while restart_choice != 'y' && restart_choice != 'n'
      print 'Do you wish to restart? (Y/N) : '
      restart_choice = gets.chomp.downcase
    end
    restart if restart_choice == 'y'
  end
end
Game.new

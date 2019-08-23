require 'json'

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

  def to_json
    JSON.dump ({
      :errors => @current_failures,
      :guesses => @current_guesses,
      :word => @current_word,
      :display => @current_word_display
    })
  end
  def self.from_json(string)
    data = JSON.load string
    self.new(data['errors'], data['guesses'], data['word'], data['display'])
  end

  protected

  @@MAX_FAILURES = 5

  def restart(errors,guesses,word,display)
    if errors.nil?
      @current_failures = 0
      @current_word = @wordlist.select_random_word
      @current_guesses = []
      @current_word_display = Array.new(@current_word.length, '_')
    else
      @current_failures = errors
      @current_word = word
      @current_guesses = guesses
      @current_word_display = display
    end
    @win = 0
    game_start
  end

  def initialize(errors=nil,guesses=nil,word=nil,display=nil)
    @wordlist = Wordlist.new
    restart(errors,guesses,word,display)
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

  def save(filename)
    if filename == ''
      print "That is not a vaild filename, try again: "
      filename = gets.chomp
      save(filename)
    elsif File.exist?(filename)
      overwrite = ''
      while overwrite != 'y' && overwrite != 'n'
        print "Do you wish to overwrite #{filename}? (Y/N): "
        overwrite = gets.chomp.downcase
      end
      if overwrite == 'y'
        File.open("saves/#{filename}.sav", 'w') do |f|
          f.write(to_json)
        end
        puts 'See you next time!'
        exit
      end
    else
      File.new("saves/#{filename}.sav", 'w+')
      File.open("saves/#{filename}.sav", 'w+') do |f|
        f.write(to_json)
        puts 'See you next time!'
        exit
      end
    end
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
      print 'Your guess (You can also type \'save\' to save your game): '
      @choice = gets.chomp
      if @choice == 'save'
        print 'Enter a filename:'
        filename = gets.chomp
        save(filename)
      elsif @choice.length != 1
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
    restart(nil,nil,nil,nil) if restart_choice == 'y'
  end
end

unless File.directory?('saves')
  Dir.mkdir('saves')
end
load = ''
while load != 'y' && load != 'n'
  print 'Do you wish to load a game? (Y/N) : '
  load = gets.chomp.downcase
end
if load == 'y'
  error_catch = ''
  while error_catch != 'n'
    puts 'Filename to load:'
    savefile = gets.chomp
    if File.exist?("saves/#{savefile}.sav")
      Game.from_json(File.read("saves/#{savefile}.sav"))
      break
    else
      print "Error: saves/#{savefile}.sav does not exist. Try again? (Y/N)"
      error_catch = gets.chomp
    end
  end
else
  Game.new
end

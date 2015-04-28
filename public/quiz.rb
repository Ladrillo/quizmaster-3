# encoding: UTF-8
require "randexp"

class MyArrays
  attr_reader :questions_array, :answers_array

  def initialize
    @questions_array = rip_lines.select {|q| rip_lines.index(q) % 2 == 0}
    @answers_array = rip_lines.select {|a| rip_lines.index(a) % 2 != 0}
  end

  def rip_lines
    IO.readlines(ARGV.first).each {|i| i.chomp}
  end
end

class Test
  attr_accessor :n_of_attempts, :points, :question, :attempt, :all_variations

  def initialize(question, answer)
    @question = question
    @pattern = eval(answer)
    @all_variations = []
    @n_of_attempts = 3
    @points = 0
    @attempt = ''
  end

  def record_attempt
    self.attempt = $stdin.gets.chomp
  end

  def to_output(player)
    File.open("mistakes/MISTAKES_#{player}.txt", "a") do |i|
      i.puts self.question
      i.puts "#{self.attempt}\n\n"
    end
  end

  def checker(player)
    loop_through_gen
    if spelling_checker == 1000
      ScreenPrint.new.success
      self.points += self.n_of_attempts ** 2
      self.n_of_attempts = 0
    else
      spelling_checker
      to_output(player)
      self.n_of_attempts -= 1
      ScreenPrint.new.incorrect(spelling_checker + 1, n_of_attempts)
      ScreenPrint.new.failure if n_of_attempts == 0
      ScreenPrint.new.correct_ans(self.all_variations[0].lstrip) if n_of_attempts == 0
    end
  end

  def gen_fix_save_variation
    generated = @pattern.gen
    question_mark_count = self.question.scan(/\?/).count
    if question_mark_count > 0
      valid = generated.gsub(/\\/,"?") if generated.scan(/\\/).count == question_mark_count
      self.all_variations << valid unless self.all_variations.include?(valid) || valid.nil?
    else
      self.all_variations << generated unless self.all_variations.include?(generated)
    end
  end

  def loop_through_gen
    (1..500).each {gen_fix_save_variation}
    #print "Correct variations: ", self.all_variations
  end

  def spelling_checker
    correctness_array = []
    split_attempt = self.attempt.split
    #print "\nSplit attempt: ", split_attempt
    self.all_variations.each do |variant|
      correctness_index = 0
      variation = variant.split
      max_index = variation.size
      #print "\nVariation: ", variation
      variation.each do |word|
        if word == split_attempt[variation.index(word)]
          correctness_index += 1
        else
          break
        end
      end
      if correctness_index < max_index
        correctness_array << correctness_index
      else
        correctness_array << 1000
      end
    end
    #print "\nCorrectness array: ", @correctness_array
    #print "\nCorrectness index: ", @correctness_array.max
    correctness_array.max
  end
end

class Game
  attr_accessor :user, :score, :questions, :answers

  def initialize
    @new_set = MyArrays.new
    @questions = @new_set.questions_array
    @answers = @new_set.answers_array
    @score = 0
    @user = ''
  end

  def player_name
    ScreenPrint.new.padding
    ScreenPrint.new.splash
    ScreenPrint.new.welcome
    self.user = $stdin.gets.chomp
  end

  def run_single_test(q)
    current_q = q
    ScreenPrint.new.header(self.questions, current_q)
    single = Test.new(current_q, self.answers[self.questions.index(current_q)])

    while single.n_of_attempts > 0
      ScreenPrint.new.current_question(current_q)
      single.record_attempt
      single.checker(user)
      self.score += single.points
    end

    ScreenPrint.new.total_score(self.score)
  end

  def run_all_tests
    player_name
    self.questions.each {|q| run_single_test(q)}
    ScreenPrint.new.efficiency(self.score, self.questions.size)
  end
end

class ScreenPrint
  def padding
    puts "\n"*50
  end

  def welcome
    puts "#{("\n"*2)}-> WELCOME TO QUIZMASTER! What is your name?"
  end

  def header(questions, current_q)
    puts "#{("\n"*2)}-> TEST #{questions.index(current_q) + 1} (of #{questions.size})\n\n"
  end

  def current_question(current_q)
    puts "#{current_q}"
  end

  def total_score(score)
    puts "\n\tYour score is #{score} points."
  end

  def efficiency(score, n_of_q)
    puts "#{("\n"*2)}-> EFFICIENCY: #{(score * 100) / (n_of_q * 9)} %#{("\n"*4)}"
  end

  def incorrect(wrong_word, n_of_attempts)
    puts "\n\tERROR at word \##{wrong_word}.\tYou have #{n_of_attempts} attempts left.\n\n"
  end

  def correct_ans(correct_variation)
    puts "\n\t#{correct_variation}"
  end

  def success
    puts '
         ___ _   _  ___ ___ ___ ___ ___ _
        / __| | | |/ __/ __| __/ __/ __| |
        \__ \ |_| | (_| (__| _|\__ \__ \_|
        |___/\___/ \___\___|___|___/___(_)'
  end

  def failure
    puts '
         █████▒▄▄▄       ██▓ ██▓     █    ██  ██▀███  ▓█████
       ▓██   ▒▒████▄    ▓██▒▓██▒     ██  ▓██▒▓██ ▒ ██▒▓█   ▀
       ▒████ ░▒██  ▀█▄  ▒██▒▒██░    ▓██  ▒██░▓██ ░▄█ ▒▒███
       ░▓█▒  ░░██▄▄▄▄██ ░██░▒██░    ▓▓█  ░██░▒██▀▀█▄  ▒▓█  ▄
       ░▒█░    ▓█   ▓██▒░██░░██████▒▒▒█████▓ ░██▓ ▒██▒░▒████▒
        ▒ ░    ▒▒   ▓▒█░░▓  ░ ▒░▓  ░░▒▓▒ ▒ ▒ ░ ▒▓ ░▒▓░░░ ▒░ ░
        ░       ▒   ▒▒ ░ ▒ ░░ ░ ▒  ░░░▒░ ░ ░   ░▒ ░ ▒░ ░ ░  ░
        ░ ░     ░   ▒    ▒ ░  ░ ░    ░░░ ░ ░   ░░   ░    ░
                    ░  ░ ░      ░  ░   ░        ░        ░  ░'
  end

  def splash
    puts '
           ____        _       __  ___           __
          / __ \__  __(_)___  /  |/  /___  _____/ / ___  _____
         / / / / / / / /_  / / /|_/ / __ `/ ___/ __/ _ \/ ___/
        / /_/ / /_/ / / / /_/ /  / / /_/ (__  ) /_/  __/ /
        \___\_\__,_/_/ /___/_/  /_/\__,_/____/\__/\___/_/
         by gabriel cabrejas'
  end
end

Game.new.run_all_tests
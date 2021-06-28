#
# Solves daily NY Times Spelling Bee puzzle:
# https://www.nytimes.com/puzzles/spelling-bee
#
# Usage:
# ruby buzzkill.rb RWYKACT
#
require 'set'
require 'pry'
require 'pp'


module BuzzKill
  # Custom Exceptions
  class UsageError < StandardError; end

  #
  # Rules
  #
  MIN_WORD_LENGTH = 4
  PANGRAM_BONUS = 7

  #
  # Constants
  #
  WORD_LIST_DIR = File.join(File.dirname(__FILE__), '../wordlists')
  WORD_LIST_FILE = 'english-109583.txt'
  USAGE_FORMAT = <<-USAGE
> %s

Usage:

  ruby buzzkill.rb [7 letters, required letter first]

Example:

  ruby buzzkill.rb RWYKACT
USAGE

  class Solver
    attr_reader :bee_words

    def self.usage(message="Welcome to buzzkill!")
      puts format(USAGE_FORMAT, message)
    end

    def initialize(bee_letters=nil)
      bee_letters = bee_letters || ARGV[0]
      @bee_letter_set = parse_bee_set(bee_letters)
      @required_letter = @bee_letter_set.first
      @word_file = parse_word_file

      msg_f = 'Solving for %s [requires: %s]'
      inform(format(msg_f, @bee_letter_set.join, @required_letter))

      msg_f = 'Using word file: %s'
      inform(format(msg_f, @word_file))
    end

    def solve
      words = []

      File.readlines(@word_file).each do |line|
        word = line.strip
        words << word.upcase if is_word?(word)
      end

      words
    end

    def solve!
      @bee_words = solve
    end

    def is_word?(word)
      return false unless word.length >= MIN_WORD_LENGTH

      # Is this any faster?
      return false unless @bee_letter_set.include? word[0].upcase

      word_letter_set = word.upcase.split('').to_set
      return false unless word_letter_set.include? @required_letter

      (word_letter_set - @bee_letter_set).empty?
    end

    def is_pangram?(word)
      word_letter_set = word.upcase.split('').to_set
      (@bee_letter_set - word_letter_set).empty?
    end

    def score(word)
      return 0 if word.length < 4
      return 1 if word.length == 4

      points = word.length
      points += PANGRAM_BONUS if is_pangram?(word)
      points
    end

    def inform(message)
      puts message
    end

    def report!
      reporter = Reporter.new(self)
      pp reporter.word_groups
      pp reporter.stats
    end

    private

    def parse_bee_set(letters)
      warning = "Don't forget to include today's letters!"
      raise UsageError.new(warning) if letters.nil?

      bee_letter_set = letters.upcase.split('').to_set
      warning = "Must include 7 letters!"
      raise UsageError.new(warning) if bee_letter_set.length != 7

      bee_letter_set
    end

    def parse_word_file
      input_fname = ARGV[1]
      file_name = input_fname.nil? ? WORD_LIST_FILE : input_fname
      File.join(WORD_LIST_DIR, file_name)
    end
  end

  class Reporter
    def initialize(solver)
      @solver = solver
    end

    def pangrams
      @pangrams ||= @solver.bee_words.select { |word| @solver.is_pangram?(word) }
    end

    def stats
      words = @solver.bee_words
      max_score = (words.map { |word| @solver.score(word) }).sum

      {
        pangrams: pangrams.length,
        count: words.length,
        max_score: max_score
      }
    end

    def word_groups
      letter_groups = {}
      word_groups = {}

      @solver.bee_words.each do |word|
        letter = word[0]
        group = letter_groups.fetch(letter, [])
        group << word
        letter_groups[letter] = group
      end

      letter_groups.each do |letter, group|
        formatted = format("(%s) %s", group.length, group.join('  '))
        word_groups[letter] = formatted
      end

      pangram_group = format("(%s) %s", pangrams.length, pangrams.join('  '))
      word_groups['PANGRAMS'] = pangram_group
      word_groups
    end
  end

  class TestSuite
    def self.test!
      test_letters = 'RWYKACT'
      solver = Solver.new(test_letters)

      solver.inform('TESTING...')

      suite = TestSuite.new(solver)
      suite.test_words
      suite.test_pangrams
      suite.test_scores

      solver.inform("Tests passed!\n\n")
    end

    def initialize(solver)
      @solver = solver
    end

    def test_words
      fail if @solver.is_word?('foo')
      fail if @solver.is_word?('act')
      fail if @solver.is_word?('tact')

      fail unless @solver.is_word?('rack')
      fail unless @solver.is_word?('tart')
      fail unless @solver.is_word?('attar')
      fail unless @solver.is_word?('tract')
      fail unless @solver.is_word?('trackway')
    end

    def test_pangrams
      fail if @solver.is_pangram?('attract')
      fail unless @solver.is_pangram?('trackway')
    end

    def test_scores
      fail unless @solver.score('rack') == 1
      fail unless @solver.score('tract') == 5
      fail unless @solver.score('trackway') == 15
    end
  end
end

#
# Main
#
BuzzKill::TestSuite.test!

begin
  solver = BuzzKill::Solver.new
  solver.solve!
  solver.report!
rescue BuzzKill::UsageError => e
  BuzzKill::Solver.usage(e.message)
end

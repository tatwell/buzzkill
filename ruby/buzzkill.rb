#
# Solves daily NY Times Spelling Bee puzzle:
# https://www.nytimes.com/puzzles/spelling-bee
#
# Usage:
# ruby buzzkill.rb RWYKACT
#
require 'set'
require 'pry'

class UsageError < StandardError; end

#
# Rules
#
MIN_WORD_LENGTH = 4
PANGRAM_BONUS = 7
WORD_LIST_DIR = File.join(File.dirname(__FILE__), '../wordlists')
WORD_LIST_FILE = 'english-109583.txt'

#
# Helper Methods
#
def usage(message="Welcome to buzzkill!")
  f = <<-USAGE
> %s

Usage:

  ruby buzzkill.rb [7 letters, require letter first]

Example:

  ruby buzzkill.rb RWYKACT
USAGE

  puts format(f, message)
end

def read_letters
  letters = ARGV[0]
  raise UsageError.new("Don't forget to include today's letters!") if letters.nil?

  bee_letter_set = letters.upcase.split('').to_set
  raise UsageError.new('Must include 7 letters!') if bee_letter_set.length != 7

  bee_letter_set
end

def is_word?(bee_letter_set, word)
  word_letter_set = word.upcase.split('').to_set

  return false unless word_letter_set.length >= MIN_WORD_LENGTH
  return false unless word_letter_set.include? bee_letter_set.first

  (word_letter_set - bee_letter_set).empty?
end

def is_pangram?(bee_letter_set, word)
  word_letter_set = word.upcase.split('').to_set
  (bee_letter_set - word_letter_set).empty?
end

def word_file
  File.join(WORD_LIST_DIR, WORD_LIST_FILE)
end

def score(word, bee_letter_set)
  return 0 if word.length < 4
  return 1 if word.length == 4

  points = word.length
  points += PANGRAM_BONUS if is_pangram?(bee_letter_set, word)
  points
end

def words_to_stats(words, bee_letter_set)
  stats = {
    words: words,
    pangrams: words.select { |word| is_pangram?(bee_letter_set, word) },
    count: words.length,
    max_score: (words.map { |word| score(word, bee_letter_set) }).sum
  }
end

#
# Public Interface
#
def test
  puts 'TESTING...'
  bee_letter_set = 'RWYKACT'.upcase.split('').to_set

  fail if is_word?(bee_letter_set, 'foo')
  fail if is_word?(bee_letter_set, 'act')
  fail if is_word?(bee_letter_set, 'tact')
  fail unless is_word?(bee_letter_set, 'rack')
  fail unless is_word?(bee_letter_set, 'tract')
  fail unless is_word?(bee_letter_set, 'trackway')

  fail if is_pangram?(bee_letter_set, 'attract')
  fail unless is_pangram?(bee_letter_set, 'trackway')

  fail unless score('rack', bee_letter_set) == 1
  fail unless score('tract', bee_letter_set) == 5
  fail unless score('trackway', bee_letter_set) == 15
  puts "Tests passed!\n"
end

def solve
  bee_words = []

  bee_letter_set = read_letters
  puts 'Solving for %s [requires: %s]' % [bee_letter_set.join, bee_letter_set.first]

  File.readlines(word_file).each do |line|
    word = line.chomp
    next unless word.length >= MIN_WORD_LENGTH
    next unless bee_letter_set.include? word[0].upcase

    bee_words << word.upcase if is_word?(bee_letter_set, word)
  end

  puts words_to_stats(bee_words, bee_letter_set)

rescue UsageError => e
  usage(e.message)
end

#
# Main
#
test
solve

require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { [*'A'..'Z'].sample }
    @score = params['score']
  end

  def score
    @word = params['word']
    @letters = JSON.parse(params['letters'])
    array = []
    @letters.each { |l| array << l if @word.include?(l.downcase) }
    grid_inc = @word.upcase.split('').all? { |c| @letters.include?(c) } && (
      array.detect { |e| array.count(e) > 1 } || array.join.downcase == @word)
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    raw_json = open(url).read
    result = JSON.parse(raw_json)
    @message = results(grid_inc, result, @word, @letters)
    @score = scoring(grid_inc, result, @word)
  end

  def results(grid_inc, result, word, letters)
    if grid_inc && result['found']
      return "Congratulations! #{word.upcase} is a valid English word!"
    elsif !grid_inc
      return "Sorry but #{word.upcase} can't be built out of #{letters}"
    else
      return "Sorry but #{word.upcase} does not seem to be a valid English word..." unless result["found"]
    end
  end

  def scoring(grid_inc, result, word)
    return word.length**2 if grid_inc && result['found']

    0
  end
end

#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class ThinkOfANumber
  include Connfu

  on :offer do |call|
    number = rand(10)
    say "I'm thinking of a number between 1 and 10"
    while ask_for_number_from_keypad(0..10) != number
      say "Sorry, guess again"
    end
    say "Congratulations"
  end
end

Connfu.start
#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class AskExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    captured_input = ask(:prompt => 'please enter your four digit pin', :digits => 4)
    p "******************* #{captured_input} ********************"
    say 'your input is ' + captured_input
    hangup
  end
end

Connfu.start AskExample
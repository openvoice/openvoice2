#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

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
#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class AnswerExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    say('hello, this is connfu')
    say('http://www.phono.com/audio/troporocks.mp3')
    hangup
  end
end

Connfu.start AnswerExample

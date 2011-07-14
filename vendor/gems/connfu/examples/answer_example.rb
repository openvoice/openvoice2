#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"
#Connfu.setup "usera@46.137.85.52", "1"

class AnswerExample
  include Connfu::Dsl

  on :offer do
    answer
    say('hello, this is connfu')
    say('http://www.phono.com/audio/troporocks.mp3')
    hangup
  end
end

Connfu.start AnswerExample

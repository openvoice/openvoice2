#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"
Connfu.redis_uri = "redis://localhost:6379/"
#Connfu.setup "usera@46.137.85.52", "1"

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

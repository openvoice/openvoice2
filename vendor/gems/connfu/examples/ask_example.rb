#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class AskExample
  include Connfu::Dsl

  raise '-------------- currently disabled --------------'
  on :offer do |call|
    answer
    ask('please enter your four digit pin') do |result|
      say 'your input is ' + result
    end
  end
end

Connfu.start AskExample
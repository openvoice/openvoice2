#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class ConferenceExample
  include Connfu::Dsl

  conference('my_conference')
end

Connfu.start ConferenceExample
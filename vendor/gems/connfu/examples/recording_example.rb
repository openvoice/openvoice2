#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

#Connfu.setup "usera@127.0.0.1", "1"
Connfu.setup "usera@46.137.85.52", "1"

class RecordingExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    start_recording

    sleep 10

    p stop_recording

    sleep 5
    hangup
  end
end

Connfu.start RecordingExample
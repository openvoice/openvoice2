#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class TransferRejected
  include Connfu::Dsl

  on :offer do |call|
    answer
    result = transfer 'sip:zlu@213.192.59.75', :timeout => 15
    puts "The transfer was rejected" if result.rejected?
  end
end

Connfu.start TransferRejected
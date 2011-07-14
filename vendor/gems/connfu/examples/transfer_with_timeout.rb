#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class TransferExample
  include Connfu::Dsl

  on :offer do
    answer
    result = transfer('sip:userb@127.0.0.1', :timeout => 15)
    puts "The transfer timed out" if result.timeout?
  end
end

Connfu.start TransferExample
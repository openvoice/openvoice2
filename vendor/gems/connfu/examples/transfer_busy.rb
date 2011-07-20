#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class TransferBusy
  include Connfu::Dsl

  on :offer do |call|
    answer
    result = transfer 'sip:zlu@213.192.59.75', :timeout => 15
#    result = transfer 'sip:zhao@81.23.228.140', :timeout => 15
    puts "The transfer was rejected because far-end is busy" if result.busy?
  end
end

Connfu.start TransferBusy
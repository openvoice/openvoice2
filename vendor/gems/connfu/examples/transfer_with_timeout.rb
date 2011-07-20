#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class TransferExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    result = transfer('sip:userb@127.0.0.1', :timeout => 15)
    puts "The transfer timed out" if result.timeout?
  end
end

Connfu.start TransferExample
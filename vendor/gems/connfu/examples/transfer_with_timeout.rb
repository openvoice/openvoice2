#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_one_recipient!

Connfu.start do
  on :offer do |call|
    answer
    result = transfer("sip:#{DIAL_TO}", :timeout => 15)
    puts "The transfer timed out" if result.timeout?
  end
end
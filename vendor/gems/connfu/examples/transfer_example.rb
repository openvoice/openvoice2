#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

TIMEOUT = ENV['TRANSFER_TIMEOUT']
MODE    = ENV['TRANSFER_MODE']

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait while we transfer your call'
    
    transfer_options = {}
    transfer_options[:timeout] = TIMEOUT.to_i if TIMEOUT
    transfer_options[:mode] = :round_robin if /round_robin/ =~ MODE
    
    result = transfer "sip:#{RECIPIENTS.first}", "sip:#{RECIPIENTS.last}", transfer_options
    
    if result.answered?
      update_status "The call was answered, and has finished"
    elsif result.busy?
      update_status "The transfer was rejected because far-end is busy"
    elsif result.rejected?
      update_status "The transfer was rejected"
    elsif result.timeout?
      update_status "The transfer timed out"
    else
      update_status "How did we get here?"
    end
  end
end
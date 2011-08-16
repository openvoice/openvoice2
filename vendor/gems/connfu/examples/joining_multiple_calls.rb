#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait'

    dial :from => call.to[:address], :to => "sip:#{RECIPIENTS.first}"
    dial :from => call.to[:address], :to => "sip:#{RECIPIENTS.last}"

    answered_result = wait_for Connfu::Event::Answered
    wait_because_of_tropo_bug_133

    send_command Connfu::Commands::Join.new(:client_jid => client_jid, :call_jid => call_jid, :call_id => answered_result.call_id)
    
    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end
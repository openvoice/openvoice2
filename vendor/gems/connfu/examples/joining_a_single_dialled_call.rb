#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_one_recipient!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait'

    dial :to => "sip:#{DIAL_TO}", :from => call.to[:address]

    wait_for Connfu::Event::Answered

    send_command Connfu::Commands::Join.new(:client_jid => client_jid, :call_jid => call_jid, :call_id => result.ref_id)

    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end
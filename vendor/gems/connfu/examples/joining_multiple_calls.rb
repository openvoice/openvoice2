#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait'

    dial_options = {
      :from => call.to[:address],
      :client_jid => Connfu.connection.jid.to_s,
      :rayo_host => Connfu.connection.jid.domain
    }
    call_1_result = send_command Connfu::Commands::Dial.new(dial_options.merge(:to => "sip:#{RECIPIENTS.first}"))
    observe_events_for(call_1_result.ref_id)

    call_2_result = send_command Connfu::Commands::Dial.new(dial_options.merge(:to => "sip:#{RECIPIENTS.last}"))
    observe_events_for(call_2_result.ref_id)

    answered_result = wait_for Connfu::Event::Answered
    sleep 1 # This is necessary, see https://github.com/tropo/tropo2/issues/133
    send_command Connfu::Commands::Join.new(:client_jid => client_jid, :call_jid => call_jid, :call_id => answered_result.call_id)
    
    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end
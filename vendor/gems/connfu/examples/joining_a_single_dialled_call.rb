#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_one_recipient!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait'

    result = send_command Connfu::Commands::Dial.new(
      :to => "sip:#{DIAL_TO}",
      :from => call.to[:address],
      :client_jid => Connfu.connection.jid.to_s,
      :rayo_host => Connfu.connection.jid.domain)
    observe_events_for(result.ref_id)

    wait_for Connfu::Event::Answered
    sleep 1 # This is necessary, see https://github.com/tropo/tropo2/issues/133
    send_command Connfu::Commands::Join.new(:client_jid => client_jid, :call_jid => call_jid, :call_id => result.ref_id)

    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end
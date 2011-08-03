#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|

    # to test that we can monitor other call events we are going to create a
    # nested join

    answer
    say 'please wait while we join'

    command_options = {
      :to => server_address,
      :from => client_address,
      :dial_to => "sip:someone@iptel.org",
      :dial_from => call.to[:address],
      :call_id => call_id
    }
    send_command Connfu::Commands::NestedJoin.new(command_options)

    presence_iq = wait_for Connfu::Event::Joined
    observe_events_for(presence_iq.joined_call_id)

    wait_for Connfu::Event::Answered
p "*************** Answered event received from other call id"

    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end

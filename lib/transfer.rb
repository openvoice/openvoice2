require 'jobs'
require 'connfu'

require File.expand_path('../../config/initializers/queue', __FILE__)

Connfu.config.uri = ENV['CONNFU_JABBER_URI']

Connfu.start do
  on :offer do |call|
    if account = Account.find_by_username(call.to[:username])
      answer
      say 'please wait while we transfer your call'

      # We must do the say before the Join happens. It will end once the join happens.
      result_iq = send_command Connfu::Commands::Say.new(
        :from => client_address,
        :to => server_address,
        :text => "http://www.phono.com/audio/troporocks.mp3"
      )

      command_options = {
        :to => server_address,
        :from => client_address,
        :dial_to => account.endpoints.first.address,
        :dial_from => call.to[:address],
        :call_id => call_id
      }

      result = send_command Connfu::Commands::NestedJoin.new(command_options)

      # the call id we are going to JOIN will be returned in the result
      observe_events_for(result.ref_id)

      # answer event for the joining call will now be handled by this "call".
      wait_for Connfu::Event::Answered

      wait_for Connfu::Event::Hangup
      @finished = true
      puts "The call was answered, and has finished"
    end
  end
end

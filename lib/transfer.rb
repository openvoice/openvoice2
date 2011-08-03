require 'connfu'

Connfu.config.uri = ENV['CONNFU_JABBER_URI']

Connfu.start do
  on :offer do |call|
    if account = Account.find_by_username(call.to[:username])
      answer
      say 'please wait while we transfer your call'

      command_options = {
        :to => server_address,
        :from => client_address,
        :dial_to => account.endpoints.first.address,
        :dial_from => call.to[:address],
        :call_id => call_id
      }
      send_command Connfu::Commands::NestedJoin.new(command_options)

      presence_iq = wait_for Connfu::Event::Joined
      observe_events_for(presence_iq.joined_call_id)

      result_iq = send_command Connfu::Commands::Say.new(
        :from => client_address,
        :to => server_address,
        :text => "http://www.phono.com/audio/troporocks.mp3"
      )

      wait_for Connfu::Event::Answered

      send_command Connfu::Commands::Stop.new(:to => server_address, :from => client_address, :ref_id => result_iq.ref_id)
      wait_for Connfu::Event::StopComplete # this could be removed later if we change the DSL to not throw an exception

      wait_for Connfu::Event::Hangup
      @finished = true
      puts "The call was answered, and has finished"
    end
  end
end

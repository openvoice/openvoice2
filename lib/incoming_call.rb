require 'jobs'
require 'connfu'

class IncomingCall
  include Connfu::Dsl
  on :offer do |call|
    if account = Account.find_by_username(call.to[:username])
      answer
      say 'please wait while we transfer your call'

      # We must do the say before the Join happens. It will end once the join happens.
      result_iq = send_command Connfu::Commands::Say.new(
                                   :call_jid => call_jid,
                                   :client_jid => client_jid,
                                   :text => "http://www.phono.com/audio/troporocks.mp3")

      command_options = {
          :call_jid =>call_jid,
          :client_jid =>client_jid,
          :dial_from => call.to[:address],
          :call_id => call_id
      }

      call_ids = []
      account.endpoints.each do |endpoint|
        result = send_command Connfu::Commands::NestedJoin.new(command_options.merge(:dial_to => endpoint.address))

        # the call id we are going to JOIN will be returned in the result
        observe_events_for(result.ref_id)
        call_ids << result.ref_id
      end
      # answer event for the joining call will now be handled by this "call".
      answered_call = wait_for Connfu::Event::Answered

      (call_ids-[answered_call.call_id]).each do |hangup_call_id|
        # hangup "#{hangup_call_id}@#{Connfu.connection.jid.domain}"
        hangup_call_jid = "#{hangup_call_id}@#{Connfu.connection.jid.domain}"
        send_command Connfu::Commands::Hangup.new(
          :call_jid => hangup_call_jid,
          :client_jid => client_jid
        )
        wait_for Connfu::Event::Hangup
      end

      wait_for Connfu::Event::Hangup
      @finished = true
      logger.debug "The call was answered, and has finished"
    end
  end
end

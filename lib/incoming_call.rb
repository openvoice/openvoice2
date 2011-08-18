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

      # wait until all are rejected or one is answered
      while (event = wait_for Connfu::Event::Answered, Connfu::Event::Rejected)
        if event.instance_of?(Connfu::Event::Rejected)
          call_ids -= [event.call_id]
          break if call_ids.empty?
          next
        elsif event.instance_of?(Connfu::Event::Answered)
          break
        end
      end

      if event.instance_of?(Connfu::Event::Answered)
        (call_ids-[event.call_id]).each do |hangup_call_id|
          hangup_call_jid = "#{hangup_call_id}@#{Connfu.connection.jid.domain}"
          send_command Connfu::Commands::Hangup.new(
            :call_jid => hangup_call_jid,
            :client_jid => client_jid
          )
          wait_for Connfu::Event::Hangup
        end

        result = wait_for Connfu::Event::Hangup
        if result.call_id == call_id # caller hangs up, hang up openvoice user
          send_command Connfu::Commands::Hangup.new(
            :call_jid => "#{event.call_id}@#{Connfu.connection.jid.domain}",
            :client_jid => client_jid
          )
          @finished = true
        end
      end

      logger.debug "The call was answered, and has finished"
    end
  end
end

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
      call_ids = []
      account.endpoints.each do |endpoint|
        call_ids << dial_join({:dial_from => call.to[:address], :dial_to => endpoint.address})
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

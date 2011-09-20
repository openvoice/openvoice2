require "connfu"

module Jobs
  class OutgoingCall
    include Connfu::Dsl

    def self.queue
      Connfu::Jobs::Dial.queue
    end

    def self.perform(call_record_id)
      call = Call.find_by_id(call_record_id)
      caller, recipient, openvoice_address = call.endpoint.address, call.party_address, call.openvoice_address
      @rejected = false

      dial :to => caller, :from => openvoice_address do |c|
        c.on_timeout do
          call.update_state!(c.state)
          hangup "#{call_id}@#{Connfu.connection.jid.domain}"
        end
        c.on_reject do
          call.update_state!(Call::REJECTED)
          if call_id != last_event_call_id
            hangup "#{call_id}@#{Connfu.connection.jid.domain}"
            @rejected = true
          end
          @finished = true
        end
        c.on_ringing do
          case last_event_call_id
            when call_id
              call.update_state!(Call::CALLER_RINGING)
            when @joined_call_id
              call.update_state!(Call::RECIPIENT_RINGING)
          end
        end
        c.on_answer do
          case last_event_call_id
            when call_id
              call.update_state!(Call::CALLER_ANSWERED)
              @joined_call_id = dial_join({:dial_to => recipient, :dial_from => openvoice_address})
            when @joined_call_id
              call.update_state!(Call::RECIPIENT_ANSWERED)
          end
        end
        c.on_busy do
          call.update_state!(Call::RECIPIENT_BUSY)
          hangup "#{call_id}@#{Connfu.connection.jid.domain}"
        end
        c.on_hangup do
          unless @rejected
            call.update_state!(Call::ENDED)
            if call_id == last_event_call_id
              hangup "#{@joined_call_id}@#{Connfu.connection.jid.domain}"
            else
              hangup
            end
          end
        end
      end
    end
  end
end

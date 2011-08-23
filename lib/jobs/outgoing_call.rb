require "connfu"

module Jobs
  class OutgoingCall
    include Connfu::Dsl

    def self.queue
      Connfu::Jobs::Dial.queue
    end

    def self.perform(call_record_id)
      call = Call.find_by_id(call_record_id)
      caller, recipient, openvoice_number = call.endpoint.address, call.recipient_address, call.openvoice_number
      @rejected = false

      dial :to => caller, :from => openvoice_number do |c|
        c.on_timeout do
          call.update_state!(:call_timed_out)
          hangup "#{call_id}@#{Connfu.connection.jid.domain}"
        end
        c.on_reject do
          call.update_state!(:call_rejected)
          if call_id != last_event_call_id
            hangup "#{call_id}@#{Connfu.connection.jid.domain}"
            @rejected = true
          end
          @finished = true
        end
        c.on_ringing do
          case last_event_call_id
            when call_id
              call.update_state!(:caller_ringing)
            when @joined_call_id
              call.update_state!(:recipient_ringing)
          end
        end
        c.on_answer do
          case last_event_call_id
            when call_id
              call.update_state!(:caller_answered)
              @joined_call_id = dial_join({:dial_to => recipient, :dial_from => openvoice_number})
            when @joined_call_id
              call.update_state!(:recipient_answered)
          end
        end
        c.on_busy do
          call.update_state!(:recipient_busy)
          hangup "#{call_id}@#{Connfu.connection.jid.domain}"
        end
        c.on_hangup do
          unless @rejected
            call.update_state!(:call_ended)
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

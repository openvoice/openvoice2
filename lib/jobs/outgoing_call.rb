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

      dial :to => caller, :from => openvoice_number do |c|
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
              command_options = {
                  :call_jid => call_jid,
                  :client_jid => client_jid,
                  :dial_to => recipient,
                  :dial_from => openvoice_number,
                  :call_id => call_id
              }
              sleep 1
              result = send_command Connfu::Commands::NestedJoin.new(command_options)
              @joined_call_id = result.ref_id
              observe_events_for(@joined_call_id)
            when @joined_call_id
              call.update_state!(:recipient_answered)
          end
        end
        c.on_hangup do
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

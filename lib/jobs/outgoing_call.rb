require "connfu"

module Jobs
  class OutgoingCall
    include Connfu::Dsl

    def self.queue
      Connfu::Jobs::Dial.queue
    end

    def self.perform(caller, recipient, openvoice_number)
      dial :to => caller, :from => openvoice_number do |c|
        c.on_answer do
          if call_id == last_event_call_id
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
          end
        end
      end
    end
  end
end

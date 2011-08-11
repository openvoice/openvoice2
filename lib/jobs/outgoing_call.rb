require "connfu"

module Jobs
  class OutgoingCall
    include Connfu::Dsl

    def self.queue
      Connfu::Jobs::Dial.queue
    end

    def self.perform(caller, recipient)
      username = "connfu"
      connfu_user = "sip:#{username}@#{Connfu.config.host}"

      dial :to => caller, :from => connfu_user do |c|
        c.on_answer do
          if call_id == last_event_call_id
            command_options = {
              :call_jid => call_jid,
              :client_jid => client_jid,
              :dial_to => recipient,
              :dial_from => connfu_user,
              :call_id => call_id
            }
            sleep 1
            result = send_command Connfu::Commands::NestedJoin.new(command_options)
            @joined_call_id = result.ref_id
            observe_events_for(@joined_call_id)
          end
        end
        c.on_hangup do
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

require "connfu"

module Jobs
  class OutgoingCall
    include Connfu::Dsl

    def self.queue
      Connfu::Jobs::Dial.queue
    end

    def self.perform(caller, recipient)
      connfu_user = "sip:connfu@127.0.0.1"

      dial :to => caller, :from => connfu_user do |c|
        c.on_answer do
          command_options = {
            :call_jid => call_jid,
            :client_jid => client_jid,
            :dial_to => recipient,
            :dial_from => connfu_user,
            :call_id => call_id
          }
          sleep 1
          result = send_command Connfu::Commands::NestedJoin.new(command_options)
          observe_events_for(result.ref_id)
        end
      end
    end
  end
end

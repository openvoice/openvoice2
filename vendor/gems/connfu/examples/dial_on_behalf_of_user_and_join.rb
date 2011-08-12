#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :ready do
    caller = "sip:#{RECIPIENTS.first}"
    recipient = "sip:#{RECIPIENTS.last}"

    connfu_jid = "sip:usera@#{Connfu.connection.jid.domain}"

    dial :to => caller, :from => connfu_jid do |c|
      c.on_ringing do
        puts "OK, ringing"
      end

      c.on_answer do
        if call_id == last_event_call_id
          puts "OK, now dialing the outbound leg"
          command_options = {
            :call_jid => call_jid,
            :client_jid => client_jid,
            :dial_to => recipient,
            :dial_from => connfu_jid,
            :call_id => call_id
          }
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
#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :ready do
    caller = "sip:#{RECIPIENTS.first}"
    recipient = "sip:#{RECIPIENTS.last}"

    connfu_user = "sip:#{Connfu.config.user}@#{Connfu.config.host}"

    dial :to => caller, :from => connfu_user do |c|
      c.on_ringing do
        puts "OK, ringing"
      end

      c.on_answer do
        if call_id == last_event_call_id
          puts "OK, now dialing the outbound leg"
          @joined_call_id = dial_join({:dial_to => recipient, :dial_from => connfu_user})
        end
      end

      c.on_hangup do
        if call_id == last_event_call_id
          hangup "#{@joined_call_id}@#{Connfu.config.host}"
        else
          hangup
        end
      end
    end
  end
end
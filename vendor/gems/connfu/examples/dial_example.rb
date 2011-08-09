#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_one_recipient!

Connfu.start do
  dial :to => "sip:#{DIAL_TO}", :from => "sip:usera@127.0.0.1"

  on :outgoing_call do |c|
    c.on_ringing do
      update_status "The phone is ringing!"
    end
    c.on_answer do
      update_status "The phone was answered!"

      sleep 2 # avoid known prism/tropo bug
      say "Though I am but a robot, my love for you is real."
      hangup
    end
    c.on_hangup do
      update_status "The phone was hung up"
    end
  end
end
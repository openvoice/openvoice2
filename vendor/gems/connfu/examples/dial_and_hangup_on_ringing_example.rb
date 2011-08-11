#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_one_recipient!

Connfu.start do
  on :ready do
    dial :to => "sip:#{DIAL_TO}", :from => "sip:usera@127.0.0.1" do |c|
      c.on_ringing do
        update_status "The phone is ringing but about to hangup!"
        hangup
      end
    end
  end
end
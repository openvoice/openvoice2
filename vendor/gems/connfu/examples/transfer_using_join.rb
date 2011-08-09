#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :offer do |call|
    answer
    say("transferring")
    transfer_using_join "sip:#{RECIPIENTS.first}", "sip:#{RECIPIENTS.last}"
    puts "Joined call has ended"
  end
end

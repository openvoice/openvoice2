#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    answer
    say("transferring")
    transfer_using_join "sip:usera@127.0.0.1", "sip:floehopper@iptel.org"
    puts "Joined call has ended"
  end
end

#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait while we round robin transfer your call'
    result = transfer "sip:#{RECIPIENTS.first}", "sip:#{RECIPIENTS.last}", :timeout => 5, :mode => :round_robin
    p result
  end
end
#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait while we transfer your call'
    result = transfer "sip:#{RECIPIENTS.first}", "sip:#{RECIPIENTS.last}"
    puts "The call was answered, and has finished" if result.answered?
  end
end
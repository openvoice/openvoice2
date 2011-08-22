#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait while we join'
    dial_join({:dial_from => call.to[:address], :dial_to => "sip:#{RECIPIENTS.first}"})
    dial_join({:dial_from => call.to[:address], :dial_to => "sip:#{RECIPIENTS.last}"})

    logger.debug "Monitoring events for #{observed_call_ids.inspect}"

    wait_for Connfu::Event::Answered
    logger.debug "The far end has answered"

    wait_for Connfu::Event::Hangup
    finish!
    logger.debug "The far end hungup"
  end
end

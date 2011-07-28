#!/usr/bin/env ruby
require File.expand_path('../../examples/environment', __FILE__)

$success = false

class DialAndHangupOnRingingExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    say('hello')
    hangup
  end

  dial :to => 'sip:usera@127.0.0.1', :from => "sip:userb@127.0.0.1"

  on :outgoing_call do |c|
    c.on_answer do
      $success = true
    end
  end
end

thread = Thread.new { Connfu.start DialAndHangupOnRingingExample }

finish_at = Time.now + 10
while !$success && Time.now < finish_at do
  sleep 1
end

if $success
  puts "\nPassed!"
else
  message = "\nFailed!\nThis might be because Prism is playing up so the first step is to restart Prism and re-run this test.\nIf it continues to fail then an upgrade to Tropo has probably broken something."
  abort message
end
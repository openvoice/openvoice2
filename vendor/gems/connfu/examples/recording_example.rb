#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    answer
    start_recording(:beep => true)
    sleep 5
    stop_recording

    hangup
    p recordings
  end
end
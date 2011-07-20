#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class RecordingExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    start_recording(:beep => true)
    sleep 5
    stop_recording

    hangup
    p recordings
  end
end

Connfu.start RecordingExample

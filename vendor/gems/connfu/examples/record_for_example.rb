#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    answer
    record_for 5
    record_for 10
    hangup

    p recordings
  end
end
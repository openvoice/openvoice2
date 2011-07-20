#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class RecordForExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    record_for 5
    hangup
    p recordings
  end
end

Connfu.start RecordForExample

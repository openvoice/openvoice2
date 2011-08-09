#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_one_recipient!

Connfu.start do
  on :offer do |call|
    redirect("sip:#{DIAL_TO}")
  end
end
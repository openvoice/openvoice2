#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    answer
    say('hello, this is connfu')
    say('http://www.phono.com/audio/troporocks.mp3')
    hangup
  end
end

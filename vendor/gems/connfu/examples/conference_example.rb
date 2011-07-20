#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class ConferenceExample
  include Connfu::Dsl

  conference('my_conference')
end

Connfu.start ConferenceExample
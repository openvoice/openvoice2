#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class RejectExample
  include Connfu::Dsl

  on :offer do |call|
    reject
  end
end

Connfu.start RejectExample
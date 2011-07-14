#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "userb@127.0.0.1", "1"

class DialExampleHelper
  include Connfu::Dsl

  on :offer do
    answer
  end
end

Connfu.start DialExampleHelper
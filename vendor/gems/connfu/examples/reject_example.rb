#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class RejectExample
  include Connfu::Dsl

  on :offer do
    reject
  end
end

Connfu.start RejectExample
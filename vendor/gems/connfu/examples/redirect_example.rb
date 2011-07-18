#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class RedirectExample
  include Connfu::Dsl

  on :offer do |call|
    redirect('sip:16508983130@127.0.0.1')
  end
end

Connfu.start RedirectExample
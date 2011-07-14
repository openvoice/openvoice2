#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class TransferExample
  include Connfu::Dsl

  on :offer do
    answer
    say 'please wait while we round robin transfer your call'
    result = transfer 'sip:openvoice@213.192.59.75', 'sip:zlu@213.192.59.75', :timeout => 5, :mode => :round_robin
    #transfer 'sip:lazyatom@213.192.59.75', 'sip:zlu@213.192.59.75', :timeout => 5, :mode => :round_robin
    #result = transfer 'sip:user1@81.218.235.58', 'sip:user2@81.218.235.58', :timeout => 8, :mode => :round_robin
    p result
  end
end

Connfu.start TransferExample
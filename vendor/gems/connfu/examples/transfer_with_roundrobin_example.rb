#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class TransferExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    say 'please wait while we round robin transfer your call'
    result = transfer 'sip:openvoice@213.192.59.75', 'sip:zlu@213.192.59.75', :timeout => 5, :mode => :round_robin
    #transfer 'sip:lazyatom@213.192.59.75', 'sip:zlu@213.192.59.75', :timeout => 5, :mode => :round_robin
    #result = transfer 'sip:user1@81.218.235.58', 'sip:user2@81.218.235.58', :timeout => 8, :mode => :round_robin
    p result
  end
end

Connfu.start TransferExample
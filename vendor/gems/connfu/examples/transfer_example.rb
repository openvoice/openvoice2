#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class TransferExample
  include Connfu::Dsl

  on :offer do |call|
    answer
    say 'please wait while we transfer your call'
    #result = transfer 'sip:zlu@213.192.59.75', 'sip:lazyatom@213.192.59.75'
    #result = transfer 'sip:openvoice@213.192.59.75', 'sip:zlu@213.192.59.75'
    result= transfer 'sip:user1@81.218.235.58', 'sip:user2@81.218.235.58'
    puts "The call was answered, and has finished" if result.answered?
  end
end

Connfu.start TransferExample
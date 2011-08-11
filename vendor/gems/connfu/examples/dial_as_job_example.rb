#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require "connfu/jobs"

class DialAsJobExample
  include Connfu::Dsl

  def self.queue
    Connfu::Jobs::Dial.queue
  end

  def self.perform(to, from)
    connfu_user = "sip:usera@127.0.0.1"
    dial :to => from, :from => connfu_user do |c|
      c.on_start   { puts "The call ID is: #{call_id}" }
      c.on_ringing { puts "... ring ring ..." }
      c.on_answer  do
        puts "call has been answered"
        puts "OK, now dialing the outbound leg"
        command_options = {
          :call_jid => call_jid,
          :client_jid => client_jid,
          :dial_to => to,
          :dial_from => connfu_user,
          :call_id => call_id
        }
        result = send_command Connfu::Commands::NestedJoin.new(command_options)
        observe_events_for(result.ref_id)
      end
      c.on_hangup  { puts "bye then." }
    end
  end
end

require "connfu/queue/resque"

if ARGV.first == "app"
  Connfu::Queue.enqueue DialAsJobExample, "sip:lazyatom@iptel.org", "sip:floehopper@iptel.org"

elsif ARGV.first == "connfu"
  # The Connfu "reactor" takes care of dequeing jobs and running them.
  Connfu.start do
  end
end
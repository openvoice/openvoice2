#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  def self.do_dial(options)
    dial(options) do |c|
      c.on_answer do
        record_for(5)
      end
    end
  end

  on :ready do
    do_dial :to => "sip:#{RECIPIENTS.first}", :from => "sip:#{Connfu.config.user}@#{Connfu.config.host}"
    do_dial :to => "sip:#{RECIPIENTS.last}", :from => "sip:#{Connfu.config.user}@#{Connfu.config.host}"
  end
end
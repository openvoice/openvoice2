require 'blather/client/client'

module Connfu
  autoload :Configuration, 'connfu/configuration'
  autoload :Connection, 'connfu/connection'
  autoload :Continuation, 'connfu/continuation'
  autoload :Commands, 'connfu/commands'
  autoload :Dsl, 'connfu/dsl'
  autoload :Event, 'connfu/event'
  autoload :EventProcessor, 'connfu/event_processor'
  autoload :Jobs, 'connfu/jobs'
  autoload :Logging, 'connfu/logging'
  autoload :Rayo, 'connfu/rayo'
  autoload :Queue, 'connfu/queue'
  autoload :TransferState, 'connfu/transfer_state'

  include Connfu::Logging

  class << self
    attr_accessor :event_processor
    attr_accessor :connection
  end

  def self.handle_stanza(stanza)
    event = Connfu::Rayo::Parser.parse_event_from(stanza)
    event_processor.handle_event(event)
  end

  def self.start(handler_class = nil, &block)
    handler_class ||= build_handler_class(&block)
    self.event_processor = EventProcessor.new(handler_class)
    EM.run do
      EventMachine::add_periodic_timer(1, Queue::Worker.new(Jobs::Dial.queue))
      connection.run
    end
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.connection
    @connection ||= Connection.new(config)
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  private

  def self.build_handler_class(&block)
    Class.new do
      include Connfu::Dsl
      instance_eval(&block)
    end
  end
end
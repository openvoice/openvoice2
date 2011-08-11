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
    attr_accessor :io_log
  end

  def self.handle_stanza(stanza)
    io_log.received stanza if io_log
    event = Connfu::Rayo::Parser.parse_event_from(stanza)
    event_processor.handle_event(event)
  end

  def self.start(handler_class = nil, &block)
    logger.info "Tropo build: #{tropo_build}"
    io_log.info "Tropo build: #{tropo_build}" if io_log
    handler_class ||= build_handler_class(&block)
    install_handler(handler_class)
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

  def self.tropo_build
    possible_prism_locations = ['~/Applications/prism', '/Applications/prism', '/opt/voxeo/prism'].map { |p| File.expand_path(p) }
    prism_home = possible_prism_locations.find { |p| File.directory?(p) }
    if prism_home && File.exist?(File.join(prism_home, "apps/tropo-build.txt"))
      File.read(File.join(prism_home, "apps/tropo-build.txt"))
    else
      "unknown"
    end
  end

  private

  def self.build_handler_class(&block)
    Class.new do
      include Connfu::Dsl
      instance_eval(&block)
    end
  end

  def self.install_handler(handler_class)
    self.event_processor = EventProcessor.new(handler_class)
    self.connection.register_handler(:ready) { handler_class.on_ready }
  end
end
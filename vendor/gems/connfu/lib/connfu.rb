%w[
  blather/client/client

  connfu/logger
  connfu/continuation
  connfu/event
  connfu/event_processor
  connfu/transfer_event
  connfu/dsl
  connfu/transfer_state
  connfu/ozone/parser
  connfu/ozone/iq_builder
  connfu/connection_adaptor
  connfu/commands/base
  connfu/queue
  connfu/queue/in_process
  connfu/jobs
].each { |file| require file }

Dir[File.expand_path("../connfu/commands/**/*.rb", __FILE__)].each do |f|
  require f
end

module Connfu
  class << self
    attr_accessor :event_processor
    attr_accessor :connection
    attr_accessor :adaptor
  end

  def self.setup(jid, password)
    @jid = jid
    @connection = Blather::Client.new.setup(jid, password)
    @adaptor = Connfu::ConnectionAdaptor.new(@connection)

    [:iq, :presence].each do |stanza_type|
      @connection.register_handler(stanza_type) do |stanza|
        l.debug "Receiving #{stanza_type} from server"
        l.debug stanza.inspect
        handle_stanza(stanza)
      end
    end
  end

  def self.handle_stanza(stanza)
    event = Connfu::Ozone::Parser.parse_event_from(stanza)
    event_processor.handle_event(event)
  end

  def self.start(handler_class)
    @connection.register_handler(:ready) do |stanza|
      l.debug "Established @connection to Connfu Server with JID: #{@jid}"
      l.debug "Queue implementation: #{Connfu::Queue.implementation.inspect}"
    end

    self.event_processor ||= EventProcessor.new(handler_class)
    EM.run do
      EventMachine::add_periodic_timer(1, DialQueueProcessor.new)
      @connection.run
    end
  end

  class DialQueueProcessor
    def call
      if job = Queue.reserve(Connfu::Jobs::Dial.queue)
        job.perform
      end
    end
  end
end
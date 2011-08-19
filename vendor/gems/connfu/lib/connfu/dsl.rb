module Connfu
  module Dsl
    autoload :Methods, "connfu/dsl/methods"
    autoload :Recording, "connfu/dsl/recording"

    def self.included(base)
      base.send(:include, Connfu::Continuation)
      base.send(:include, Connfu::Dsl::Methods)
      base.send(:include, Connfu::Dsl::Recording)
      base.send(:include, Connfu::Logging)
      base.extend Connfu::Dsl::ClassMethods
      base.class_eval do
        attr_reader :call_jid, :client_jid, :call_id
        attr_accessor :call_behaviour, :last_event_call_id
      end
    end

    class CallBehaviour
      def on_start(&block)
        @on_start = block if block_given?
        @on_start
      end

      def on_ringing(&block)
        @on_ringing = block if block_given?
        @on_ringing
      end

      def on_answer(&block)
        @on_answer = block if block_given?
        @on_answer
      end

      def on_hangup(&block)
        @on_hangup = block if block_given?
        @on_hangup
      end

      def on_reject(&block)
        @on_reject = block if block_given?
        @on_reject
      end

      def on_timeout(&block)
        @on_timeout = block if block_given?
        @on_timeout
      end
    end

    def on_offer(event=nil)
    end

    module ClassMethods
      def on_ready
        instance_eval(&@ready_block) if @ready_block
      end

      def on(context, &block)
        case context
          when :ready
            @ready_block = block
          when :offer
            define_method(:on_offer, &block)
          else
            raise "Unrecognised context: #{context}"
        end
      end

      def dial(options={})
        instance = new({})
        instance.call_behaviour = CallBehaviour.new
        yield instance.call_behaviour if block_given?
        Connfu.event_processor.handlers << instance
        options = {
          :to => options[:to],
          :from => options[:from],
          :headers => options[:headers],
          :client_jid => Connfu.connection.jid.to_s,
          :rayo_host => Connfu.connection.jid.domain
        }
        options.delete(:headers) if options[:headers].nil?
        instance.send_command_without_waiting Connfu::Commands::Dial.new(options)
      end
    end

    def initialize(params)
      self.call_jid = params[:call_jid]
      self.client_jid = params[:client_jid]
      self.call_id = params[:call_id]
    end

    def call_jid=(jid)
      @call_jid ||= jid
    end

    def client_jid=(jid)
      @client_jid ||= jid
    end

    def call_id=(id)
      @call_id ||= id
    end

    def finished?
      @finished == true
    end

    def run_any_call_behaviour_for(event_name)
      if call_behaviour && behaviour = call_behaviour.send("on_#{event_name}")
        start { instance_eval(&behaviour) }
      end
    end

    def handle_event(event)
      logger.debug "Handling event: %p" % event
      self.last_event_call_id = event.call_id
      if expected_dial_result?(event)
        self.call_id = event.ref_id
        run_any_call_behaviour_for(:start)
      elsif waiting_for?(event)
        continue(event)
      else
        case event
          when Connfu::Event::Offer
            start do
              on_offer event
              hangup unless finished?
            end
          when Connfu::Event::Ringing
            self.client_jid = event.presence_to
            self.call_jid = event.presence_from
            run_any_call_behaviour_for(:ringing)
          when Connfu::Event::Rejected
            run_any_call_behaviour_for(:reject)
          when Connfu::Event::Timeout
            run_any_call_behaviour_for(:timeout)
          when Connfu::Event::Answered
            wait_because_of_tropo_bug_133
            run_any_call_behaviour_for(:answer)
          when Connfu::Event::Hangup
            run_any_call_behaviour_for(:hangup)
            @finished = true
          else
            logger.warn "Unrecognized event: %p" % event
        end
      end
    end

    def can_handle_event?(event)
      event_matches_call_id?(event) || event_matches_last_command_id?(event)
    end

    def send_command_without_waiting(command)
      @last_command_id = Connfu.connection.send_command command
      logger.debug "Sent command: %p" % command
    end

    def send_command(command)
      return if @finished
      send_command_without_waiting command
      result = wait_for Connfu::Event::Result, Connfu::Event::Error
      logger.debug "Result from command: %p" % result
      if result.is_a?(Connfu::Event::Error)
        raise
      else
        result
      end
    end

    def observe_events_for(call_id)
      observed_call_ids << call_id
    end

    def wait_because_of_tropo_bug_133
      Connfu.connection.wait_because_of_tropo_bug_133
    end

    private

    def event_matches_call_id?(event)
      event.call_id == call_id || observed_call_ids.include?(event.call_id)
    end

    def event_matches_last_command_id?(event)
      event.respond_to?(:command_id) && @last_command_id == event.command_id
    end

    def waiting_for?(event)
      can_handle_event?(event) && @waiting_for && @waiting_for.detect do |e|
        e === event
      end
    end

    def expected_dial_result?(event)
      event.is_a?(Connfu::Event::Result) && waiting_for_dial_result?
    end

    def waiting_for_dial_result?
      @call_id.nil?
    end

    def observed_call_ids
      @observed_call_ids ||= []
    end

    def wait_for(*events)
      @waiting_for = events
      wait
    end
  end
end
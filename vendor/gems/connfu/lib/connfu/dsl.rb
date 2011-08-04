module Connfu
  module Dsl
    def self.included(base)
      base.send(:include, Connfu::Continuation)
      base.send(:include, Connfu::Dsl::InstanceMethods)
      base.send(:include, Connfu::Logging)
      base.extend Connfu::Dsl::ClassMethods
      base.class_eval do
        attr_reader :server_address, :client_address, :call_id
      end
    end

    class CallBehaviour
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
    end

    module ClassMethods
      def on(context, &block)
        case context
          when :offer
            define_method(:run, &block)
          when :outgoing_call
            call_behaviour = CallBehaviour.new
            yield call_behaviour
            define_method(:call_behaviour) { call_behaviour }
          else
            raise "Unrecognised context: #{context}"
        end

      end

      def dial(options={})
        Queue.enqueue(Jobs::Dial, options)
      end
    end

    module InstanceMethods

      def run(*args)
      end

      def finished?
        @finished == true
      end

      def say(text)
        send_command Connfu::Commands::Say.new(:text => text, :to => server_address, :from => client_address)
        wait_for Connfu::Event::SayComplete
      end

      def ask(options)
        send_command Connfu::Commands::Ask.new(:prompt => options[:prompt], :digits => options[:digits], :from => client_address, :to => server_address)
        ask_complete = wait_for Connfu::Event::AskComplete
        ask_complete.captured_input
      end

      def answer
        send_command Connfu::Commands::Answer.new(:to => server_address, :from => client_address)
      end

      def reject
        send_command Connfu::Commands::Reject.new(:to => server_address, :from => client_address)
      end

      def hangup
        send_command Connfu::Commands::Hangup.new(:to => server_address, :from => client_address)
        wait_for Connfu::Event::Hangup
        @finished = true
      end

      def redirect(redirect_to)
        send_command Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :to => server_address, :from => client_address)
      end

      def transfer(*transfer_to)
        options = transfer_to.last.is_a?(Hash) ? transfer_to.pop : {}
        if options.delete(:mode) == :round_robin
          result = nil
          transfer_to.each do |sip_address|
            result = transfer sip_address, options
            break if result.answered?
          end
          return result
        else
          command_options = {:transfer_to => transfer_to, :to => server_address, :from => client_address}
          command_options[:timeout] = options[:timeout] * 1000 if options[:timeout]
          send_command Connfu::Commands::Transfer.new(command_options)
          transfer_event = wait_for Connfu::Event::TransferEvent
          transfer_event.state
        end
      end

      def transfer_using_join(dial_from, dial_to)
        command_options = {
          :to => server_address,
          :from => client_address,
          :dial_to => dial_to,
          :dial_from => dial_from,
          :call_id => call_id
        }
        send_command Connfu::Commands::NestedJoin.new(command_options)
        wait_for Connfu::Event::Hangup
        @finished = true
      end

      def recordings
        @recordings ||= []
      end

      def start_recording(options = {})
        send_start_recording(options)
      end

      def record_for(max_length, options = {})
        send_start_recording(options.merge(:max_length => max_length))
        event = wait_for(Connfu::Event::RecordingStopComplete)
        recordings << event.uri
      end

      def stop_recording
        send_command Connfu::Commands::Recording::Stop.new(:to => server_address, :from => client_address, :ref_id => @ref_id)
        event = wait_for(Connfu::Event::RecordingStopComplete)
        recordings << event.uri
      end

      def run_any_call_behaviour_for(event)
        if respond_to?(:call_behaviour) && behaviour = call_behaviour.send("on_#{event}")
          start { instance_eval(&behaviour) }
        end
      end

      def handle_event(event)
        logger.debug "Handling event: #{event.inspect}"

        if waiting_for?(event)
          continue(event)
        else
          case event
            when Connfu::Event::Offer
              start do
                run event
                hangup unless finished?
              end
            when Connfu::Event::Ringing
              run_any_call_behaviour_for(:ringing)
            when Connfu::Event::Answered
              run_any_call_behaviour_for(:answer)
            when Connfu::Event::Hangup
              run_any_call_behaviour_for(:hangup)
              @finished = true
            else
              logger.warn "Unrecognized event: #{event}"
          end
        end
      end

      def can_handle_event?(event)
        event_matches_call_id?(event) || event_matches_last_command_id?(event)
      end

      def waiting_for?(event)
        can_handle_event?(event) && @waiting_for && @waiting_for.detect do |e|
          e === event
        end
      end

      def send_command(command)
        return if @finished
        @last_command_id = Connfu.connection.send_command command
        logger.debug "Sent command: #{command}"
        result = wait_for Connfu::Event::Result, Connfu::Event::Error
        logger.debug "Result from command #{result}"
        if result.is_a?(Connfu::Event::Error)
          raise
        else
          result
        end
      end

      def observe_events_for(call_id)
        observed_call_ids << call_id
      end

      private

      def event_matches_call_id?(event)
        event.call_id == call_id || observed_call_ids.include?(event.call_id)
      end

      def event_matches_last_command_id?(event)
        event.respond_to?(:command_id) && @last_command_id == event.command_id
      end

      def observed_call_ids
        @observed_call_ids ||= []
      end

      def send_start_recording(options = {})
        command_options = { :to => server_address, :from => client_address }
        command_options[:max_length] = options[:max_length] * 1000 if options[:max_length]
        command_options[:beep] = options[:beep] if options.has_key?(:beep)
        command_options[:format] = options[:format] if options.has_key?(:format)
        command_options[:codec] = options[:codec] if options.has_key?(:codec)
        result = send_command Connfu::Commands::Recording::Start.new(command_options)
        @ref_id = result.ref_id
      end

      def wait_for(*events)
        @waiting_for = events
        wait
      end

    end

    def initialize(params)
      @server_address = params[:from]
      @client_address = params[:to]
      @call_id = params[:call_id]
    end
  end
end
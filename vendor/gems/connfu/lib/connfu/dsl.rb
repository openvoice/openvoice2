module Connfu
  module Dsl
    def self.included(base)
      base.send(:include, Connfu::Continuation)
      base.send(:include, Connfu::Dsl::InstanceMethods)
      base.extend Connfu::Dsl::ClassMethods
      base.class_eval do
        attr_reader :server_address, :client_address
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
        define_method(:run, &block)
      end

      def dial(params={}, &block)
        self.class.send(:define_method, :on_ready) do
          Connfu.adaptor.send_command Connfu::Commands::Dial.new(params)
        end
        call_behaviour = CallBehaviour.new
        yield call_behaviour
        define_method(:call_behaviour) { call_behaviour }
      end
    end

    module InstanceMethods
      def run
      end

      def finished?
        @finished == true
      end

      def say(text)
        send_command Connfu::Commands::Say.new(:text => text, :to => server_address, :from => client_address)
        wait
      end

      def answer
        send_command Connfu::Commands::Answer.new(:to => server_address, :from => client_address)
      end

      def reject
        send_command Connfu::Commands::Reject.new(:to => server_address, :from => client_address)
      end

      def hangup
        send_command Connfu::Commands::Hangup.new(:to => server_address, :from => client_address)
        wait
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
          wait
        end
      end

      def start_recording
        send_command Connfu::Commands::Recording::Start.new(:to => server_address, :from => client_address)
      end

      def stop_recording
        send_command Connfu::Commands::Recording::Stop.new(:to => server_address, :from => client_address, :ref_id => @ref_id)
        wait
      end

      def run_any_call_behaviour_for(event)
        if respond_to?(:call_behaviour) && behaviour = call_behaviour.send("on_#{event}")
          start { instance_eval(&behaviour) }
        end
      end

      def handle_event(event)
        l.debug "Handling event: #{event.inspect}"
        case event
          when Connfu::Event::Offer
            start(event)
          when Connfu::Event::Ringing
            run_any_call_behaviour_for(:ringing)
          when Connfu::Event::Answered
            run_any_call_behaviour_for(:answer)
          when Connfu::Event::SayComplete
            continue
          when Connfu::Event::TransferSuccess
            continue(TransferState.answered)
          when Connfu::Event::TransferTimeout
            continue(TransferState.timeout)
          when Connfu::Event::TransferRejected
            continue(TransferState.rejected)
          when Connfu::Event::TransferBusy
            continue(TransferState.busy)
          when Connfu::Event::Result
            @ref_id = event.ref_id
            continue
          when Connfu::Event::Hangup
            run_any_call_behaviour_for(:hangup)
            @finished = true
            continue
          when Connfu::Event::Error
            continue(:error)
          when Connfu::Event::RecordingStopComplete
            continue
        end
      end

      private

      def send_command(command)
        return if @finished
        Connfu.adaptor.send_command command
        l.debug "Sent command: #{command}"
        result = wait
        l.debug "Result from command #{result}"
        raise if result == :error
      end
    end

    def initialize(params)
      @server_address = params[:from]
      @client_address = params[:to]
    end

  end
end
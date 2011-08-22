module Connfu
  module Dsl
    module Recording
      def recordings
        @recordings ||= []
      end

      def start_recording(options = {})
        send_start_recording(options)
      end

      def record_for(max_length, options = {})
        send_start_recording(options.merge(:max_length => max_length))
        event = wait_for(Connfu::Event::RecordingStopComplete, Connfu::Event::RecordingHangupComplete)
        recordings << event.uri
      end

      def stop_recording
        send_command Connfu::Commands::Recording::Stop.new(:call_jid => call_jid, :client_jid => client_jid, :ref_id => @ref_id)
        event = wait_for(Connfu::Event::RecordingStopComplete)
        recordings << event.uri
      end

      private

      def send_start_recording(options = {})
        command_options = { :call_jid => call_jid, :client_jid => client_jid }
        command_options[:max_length] = options[:max_length] * 1000 if options[:max_length]
        command_options[:beep] = options[:beep] if options.has_key?(:beep)
        command_options[:format] = options[:format] if options.has_key?(:format)
        command_options[:codec] = options[:codec] if options.has_key?(:codec)
        result = send_command Connfu::Commands::Recording::Start.new(command_options)
        @ref_id = result.ref_id
      end
    end
  end
end
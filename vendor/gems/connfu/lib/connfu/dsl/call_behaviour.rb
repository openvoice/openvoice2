module Connfu
  module Dsl
    class CallBehaviour
      attr_reader :state

      def on_start(&block)
        @state = :started
        @on_start = block if block_given?
        @on_start
      end

      def on_ringing(&block)
        @state = :ringing
        @on_ringing = block if block_given?
        @on_ringing
      end

      def on_answer(&block)
        @state = :answered
        @on_answer = block if block_given?
        @on_answer
      end

      def on_hangup(&block)
        @state = :hangup
        @on_hangup = block if block_given?
        @on_hangup
      end

      def on_reject(&block)
        @state = :rejected
        @on_reject = block if block_given?
        @on_reject
      end

      def on_timeout(&block)
        @state = :timeout
        @on_timeout = block if block_given?
        @on_timeout
      end

      def on_busy(&block)
        @state = :busy
        @on_busy = block if block_given?
        @on_busy
      end
    end
  end
end

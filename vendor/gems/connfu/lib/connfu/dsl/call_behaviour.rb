module Connfu
  module Dsl
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

      def on_busy(&block)
        @on_busy = block if block_given?
        @on_busy
      end
    end
  end
end

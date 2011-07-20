require "json"

module Connfu
  module Queue
    class InProcess
      class Message
        attr_reader :args

        def initialize(klass, *args)
          @klass, @args = klass, JSON.parse(args.to_json)
        end

        def perform
          @klass.perform(*@args)
        end
      end

      def initialize
        clear
      end

      def clear
        @queues = Hash.new { |queues, queue| queues[queue] = [] }
      end

      def enqueue(klass, *args)
        @queues[klass.queue].unshift(Message.new(klass, *args))
      end

      def reserve(queue)
        @queues[queue].pop
      end

      def size(queue)
        @queues[queue].length
      end
    end
  end
end
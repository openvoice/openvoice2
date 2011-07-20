require "resque"

module Connfu
  module Queue
    module Resque
      extend ::Resque

      def self.clear
        redis.flushall
      end
    end
  end
end

Connfu::Queue.implementation = Connfu::Queue::Resque
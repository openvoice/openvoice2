module Connfu
  module Queue
    class Worker
      def initialize(queue)
        @queue = queue
      end

      def call
        if job = Queue.reserve(@queue)
          job.perform
        end
      end
    end
  end
end

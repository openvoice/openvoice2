require 'connfu/transfer_state'

module Connfu
  module Event
    class TransferEvent < Presence
      def self.parse(node)
        return unless (results = node.xpath("//x:*", 'x' => tropo('transfer:complete:1'))).any?
        Connfu::TransferState.event_map[results.first.name.to_sym].new(:call_id => node.from.node)
      end
    end

    class TransferSuccess < TransferEvent
      def state
        TransferState.answered
      end
    end

    class TransferTimeout < TransferEvent
      def state
        TransferState.timeout
      end
    end

    class TransferRejected < TransferEvent
      def state
        TransferState.rejected
      end
    end

    class TransferBusy < TransferEvent
      def state
        TransferState.busy
      end
    end
  end
end
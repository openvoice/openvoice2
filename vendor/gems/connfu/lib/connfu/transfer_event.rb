module Connfu
  module Event
    class TransferEvent < Presence
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
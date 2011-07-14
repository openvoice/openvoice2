module Connfu
  module Event
    class TransferSuccess < Presence
    end

    class TransferTimeout < Presence
    end

    class TransferRejected < Presence
    end

    class TransferBusy < Presence
    end
  end
end
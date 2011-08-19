module Connfu
  module Event
    autoload :TransferEvent, 'connfu/event/transfer_event'
    autoload :TransferSuccess, 'connfu/event/transfer_event'
    autoload :TransferTimeout, 'connfu/event/transfer_event'
    autoload :TransferRejected, 'connfu/event/transfer_event'
    autoload :TransferBusy, 'connfu/event/transfer_event'

    class Base
      attr_reader :call_id

      def initialize(params = {})
        @call_id = params[:call_id]
      end
    end

    class Result < Base
      attr_reader :call_id, :ref_id, :command_id

      def initialize(params = {})
        super
        @ref_id = params[:ref_id]
        @command_id = params[:command_id]
      end
    end

    class Error < Base
      attr_reader :call_id, :command_id

      def initialize(params = {})
        super
        @command_id = params[:command_id]
      end
    end

    class Presence < Base
    end

    class Offer < Presence

      attr_reader :presence_from, :presence_to
      attr_reader :from, :to

      def initialize(params)
        super
        @presence_from = params[:presence_from]
        @presence_to = params[:presence_to]
        @from = params[:from]
        @to = parse_address(params[:to])
      end

      def parse_address(raw_address)
        address, scheme, username, host = *raw_address.match(%r{^<?([^:]+):([^@]+)@([^>]+)>?$})
        {
          :address => address.match(%r{^<?([^>]+)>?$})[1],
          :scheme => scheme,
          :username => username,
          :host => host
        }
      end
    end

    class SayComplete < Presence
    end

    class AskComplete < Presence
      attr_reader :captured_input

      def initialize(params = {})
        super
        @captured_input = params[:captured_input]
      end
    end

    class Ringing < Presence
      attr_reader :presence_from, :presence_to

      def initialize(params)
        super
        @presence_from = params[:from]
        @presence_to = params[:to]
      end
    end

    class Answered < Presence
    end

    class Hangup < Presence
    end

    class Rejected < Presence
    end

    class Timeout < Presence
    end

    class Busy < Presence
    end

    class StopComplete < Presence
    end

    class RecordingStopComplete < Presence
      attr_reader :uri

      def initialize(params = {})
        super
        @uri = params[:uri]
      end
    end

    class Joined < Presence
      attr_reader :joined_call_id

      def initialize(params = {})
        super(params)
        @joined_call_id = params[:joined_call_id]
      end
    end

    class Unjoined < Presence
      attr_reader :unjoined_call_id

      def initialize(params = {})
        super(params)
        @unjoined_call_id = params[:unjoined_call_id]
      end
    end
  end
end
module Connfu
  module Event
    autoload :TransferEvent, 'connfu/event/transfer_event'
    autoload :TransferSuccess, 'connfu/event/transfer_event'
    autoload :TransferTimeout, 'connfu/event/transfer_event'
    autoload :TransferRejected, 'connfu/event/transfer_event'
    autoload :TransferBusy, 'connfu/event/transfer_event'

    class Presence
      attr_reader :call_id

      def initialize(params = {})
        @call_id = params[:call_id]
      end
    end

    class Offer < Presence

      attr_reader :presence_from, :presence_to
      attr_reader :from, :to

      def initialize(params)
        @presence_from = params[:presence_from]
        @presence_to = params[:presence_to]
        @call_id = params[:call_id]
        @from = params[:from]
        @to = parse_address(params[:to])
      end

      def parse_address(raw_address)
        address, scheme, username, host = *raw_address.match(%r{^<([^:]+):([^@]+)@([^>]+)>$})
        {
          :address => address,
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
        @call_id = params[:call_id]
        @captured_input = params[:captured_input]
      end
    end

    class Result
      attr_reader :call_id, :ref_id

      def initialize(params = {})
        @call_id = params[:call_id]
        @ref_id = params[:ref_id]
      end
    end

    class Error
      attr_reader :call_id

      def initialize(params = {})
        @call_id = params[:call_id]
      end
    end

    class Ringing < Presence
      attr_reader :presence_from, :presence_to

      def initialize(params)
        @presence_from = params[:from]
        @presence_to = params[:to]
        @call_id = params[:call_id]
      end
    end

    class Answered < Presence
    end

    class Hangup < Presence
    end

    class RecordingStopComplete < Presence
      attr_reader :uri

      def initialize(params = {})
        @call_id = params[:call_id]
        @uri = params[:uri]
      end
    end
  end
end
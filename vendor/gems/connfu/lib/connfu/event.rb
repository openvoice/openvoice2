module Connfu
  module Event
    [:TransferBusy, :TransferEvent, :TransferRejected, :TransferSuccess, :TransferTimeout].each do |t|
      autoload t, 'connfu/event/transfer_event'
    end

    class Base
      extend Connfu::Rayo::Namespacing

      attr_reader :call_id

      def initialize(params = {})
        @call_id = params[:call_id]
      end
    end

    class Result < Base
      attr_reader :ref_id, :command_id

      def self.parse(node)
        return unless node.type == :result
        if ref = node.xpath('x:ref', 'x' => rayo('1')).first
          new(:call_id => node.from.node, :ref_id => ref.attributes['id'].value, :command_id => node.attributes['id'].value)
        else
          new(:call_id => node.from.node, :command_id => node.attributes['id'].value)
        end
      end

      def initialize(params = {})
        super
        @ref_id = params[:ref_id]
        @command_id = params[:command_id]
      end
    end

    class Error < Base
      attr_reader :command_id

      def self.parse(node)
        return unless node.type == :error
        new(:call_id => node.from.node, :command_id => node.attributes['id'].value)
      end

      def initialize(params = {})
        super
        @command_id = params[:command_id]
      end
    end

    class Presence < Base
      attr_reader :presence_from, :presence_to

      def initialize(params = {})
        super
        @presence_from = params[:presence_from].nil? ? params[:from] : params[:presence_from]
        @presence_to = params[:presence_to].nil? ? params[:to] : params[:presence_to]
      end
    end

    class Offer < Presence
      attr_reader :from, :to

      def self.parse(node)
        return unless node.xpath('//x:offer', 'x' => rayo('1')).any?
        new(offer_params(node).merge(:call_id => node.from.node))
      end

      def self.offer_params(node)
        presence_node = node.xpath('/presence').first
        p_attrs = presence_node.attributes
        offer = node.xpath('//x:offer', 'x' => rayo('1')).first
        from = offer.xpath('x:header[@name="From"]', 'x' => rayo('1')).first["value"]
        to = offer.xpath('x:header[@name="To"]', 'x' => rayo('1')).first["value"]
        {:presence_from => p_attrs['from'].value, :presence_to => p_attrs['to'].value, :from => from, :to => to}
      end

      def initialize(params = {})
        super
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
      def self.parse(node)
        return unless node.xpath('//x:success', 'x' => tropo('say:complete:1')).any?
        new(:call_id => node.from.node, :from => node.from)
      end
    end

    class AskComplete < Presence
      attr_reader :captured_input

      def self.parse(node)
        return unless complete = node.xpath('//x:success', 'x' => tropo('ask:complete:1')).first
        captured_input = complete.xpath('//x:interpretation', 'x' => tropo('ask:complete:1')).first.inner_text
        new(:call_id => node.from.node, :captured_input => captured_input)
      end

      def initialize(params = {})
        super
        @captured_input = params[:captured_input]
      end
    end

    class Ringing < Presence
      def self.parse(node)
        return unless node.xpath('//x:ringing', 'x' => rayo('1')).any?
        new(:call_id => node.from.node, :to => node.to.to_s, :from => node.from.to_s)
      end
    end

    class Answered < Presence
      def self.parse(node)
        return unless node.xpath('//x:answered', 'x' => rayo('1')).any?
        new(:call_id => node.from.node)
      end
    end

    class Hangup < Presence
      def self.parse(node)
        return unless node.xpath("//x:hangup", 'x' => rayo('1')).any? || node.xpath("//x:hangup", 'x' => rayo('ext:complete:1')).any?
        return if node.xpath('//x:recording', 'x' => rayo('record:complete:1')).first
        new(:call_id => node.from.node, :from => node.from)
      end
    end

    class Rejected < Presence
      def self.parse(node)
        return unless node.xpath("//x:reject", 'x' => rayo('1')).any?
        new(:call_id => node.from.node)
      end
    end

    class Timeout < Presence
      def self.parse(node)
        return unless node.xpath('//x:timeout', 'x' => rayo('1')).any?
        new(:call_id => node.from.node)
      end
    end

    class Busy < Presence
      def self.parse(node)
        return unless node.xpath('//x:busy', 'x' => rayo('1')).any?
        new(:call_id => node.from.node)
      end
    end

    class StopComplete < Presence
      def self.parse(node)
        return unless node.xpath('//x:stop', 'x' => rayo('ext:complete:1')).first
        return if recording_element = node.xpath('//x:recording', 'x' => rayo('record:complete:1')).first
        new(:call_id => node.from.node)
      end
    end

    class RecordingStopComplete < Presence
      attr_reader :uri

      def self.parse(node)
        return unless node.xpath('//x:stop', 'x' => rayo('ext:complete:1')).first
        return unless recording_element = node.xpath('//x:recording', 'x' => rayo('record:complete:1')).first
        new(:call_id => node.from.node, :uri => recording_element.attributes['uri'].value)
      end

      def initialize(params = {})
        super
        @uri = params[:uri]
      end
    end

    class RecordingHangupComplete < Presence
      attr_reader :uri

      def self.parse(node)
        return unless node.xpath('//x:hangup', 'x' => rayo('ext:complete:1')).first
        return unless recording_element = node.xpath('//x:recording', 'x' => rayo('record:complete:1')).first
        new(:call_id => node.from.node, :uri => recording_element.attributes['uri'].value, :from => node.from, :to => node.to)
      end

      def initialize(params = {})
        super
        @uri = params[:uri]
      end
    end

    class Joined < Presence
      attr_reader :joined_call_id

      def self.parse(node)
        return unless joined = node.xpath('//x:joined', 'x' => rayo('1')).first
        new(:call_id => node.from.node, :joined_call_id => joined.attributes['call-id'].value)
      end

      def initialize(params = {})
        super(params)
        @joined_call_id = params[:joined_call_id]
      end
    end

    class Unjoined < Presence
      attr_reader :unjoined_call_id

      def self.parse(node)
        return unless unjoined = node.xpath('//x:unjoined', 'x' => rayo('1')).first
        new(:call_id => node.from.node, :unjoined_call_id => unjoined.attributes['call-id'].value)
      end

      def initialize(params = {})
        super(params)
        @unjoined_call_id = params[:unjoined_call_id]
      end
    end

    EVENT_CLASSES = [Offer, SayComplete, Result, Error, Ringing, Answered, Hangup, Rejected, Timeout, Busy, RecordingHangupComplete, RecordingStopComplete, StopComplete, AskComplete, Joined, Unjoined, TransferEvent]

    def self.parse(node)
      event = nil
      EVENT_CLASSES.detect { |klass| event = klass.parse(node) }
      event
    end
  end
end
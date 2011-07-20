module Connfu
  module Ozone
    module Parser

      def self.parse_event_from(node)
        call_id = node.from.node
        to = node.from.to_s
        from = node.to.to_s

        if node.xpath('//x:offer', 'x' => 'urn:xmpp:ozone:1').any?
          Connfu::Event::Offer.new(offer_params(node).merge(:call_id => call_id))
        elsif node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:say:complete:1').any?
          Connfu::Event::SayComplete.new(:call_id => call_id)
        elsif node.type == :result
          if (ref = node.xpath('x:ref', 'x' => 'urn:xmpp:ozone:1').first)
            Connfu::Event::Result.new(:call_id => call_id, :ref_id => ref.attributes['id'].value)
          else
            Connfu::Event::Result.new(:call_id => call_id)
          end
        elsif node.type == :error
          Connfu::Event::Error.new(:call_id => call_id)
        elsif node.xpath('//x:ringing', 'x' => 'urn:xmpp:ozone:1').any?
          Connfu::Event::Ringing.new(:call_id => call_id, :to => from, :from => to)
        elsif node.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').any?
          Connfu::Event::Answered.new(:call_id => call_id)
        elsif node.xpath("//x:hangup", 'x' => "urn:xmpp:ozone:1").any?
          Connfu::Event::Hangup.new(:call_id => call_id)
        elsif stop = node.xpath('//x:stop', 'x' => 'urn:xmpp:ozone:ext:complete:1').first
          recording_element = node.xpath('//x:recording', 'x' => 'urn:xmpp:ozone:ext:1').first
          Connfu::Event::RecordingStopComplete.new(:call_id => call_id, :uri => recording_element.attributes['uri'].value)
        elsif complete = node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:ask:complete:1').first
          captured_input = complete.xpath('//x:interpretation', 'x' => 'urn:xmpp:ozone:ask:complete:1').first.inner_text
          Connfu::Event::AskComplete.new(:call_id => call_id, :captured_input => captured_input)
        else
          self.transfer_complete?(node)
        end
      end

      def self.transfer_complete?(node)
        Connfu::TransferState.event_map.each do |k, v|
          if node.xpath("//x:#{k}", 'x' => 'urn:xmpp:ozone:transfer:complete:1').any?
            return v.new(:call_id => node.from.node)
          end
        end
      end

      private

      def self.offer_params(node)
        presence_node = node.xpath('/presence').first
        p_attrs = presence_node.attributes
        offer = node.xpath('//x:offer', 'x' => 'urn:xmpp:ozone:1').first
        from = offer.xpath('x:header[@name="From"]', 'x' => 'urn:xmpp:ozone:1').first["value"]
        to = offer.xpath('x:header[@name="To"]', 'x' => 'urn:xmpp:ozone:1').first["value"]
        {:presence_from => p_attrs['from'].value, :presence_to => p_attrs['to'].value,
         :from => from, :to => to}
      end
    end
  end
end
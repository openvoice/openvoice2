module Connfu
  module Rayo
    module Parser
      extend Connfu::Rayo::Namespacing

      def self.parse_event_from(node)
        call_id = node.from.node
        to = node.from.to_s
        from = node.to.to_s

        if node.xpath('//x:offer', 'x' => rayo('1')).any?
          Connfu::Event::Offer.new(offer_params(node).merge(:call_id => call_id))
        elsif node.xpath('//x:success', 'x' => tropo('say:complete:1')).any?
          Connfu::Event::SayComplete.new(:call_id => call_id)
        elsif node.type == :result
          if (ref = node.xpath('x:ref', 'x' => rayo('1')).first)
            Connfu::Event::Result.new(:call_id => call_id, :ref_id => ref.attributes['id'].value, :command_id => node.attributes['id'].value)
          else
            Connfu::Event::Result.new(:call_id => call_id, :command_id => node.attributes['id'].value)
          end
        elsif node.type == :error
          Connfu::Event::Error.new(:call_id => call_id, :command_id => node.attributes['id'].value)
        elsif node.xpath('//x:ringing', 'x' => rayo('1')).any?
          Connfu::Event::Ringing.new(:call_id => call_id, :to => from, :from => to)
        elsif node.xpath('//x:answered', 'x' => rayo('1')).any?
          Connfu::Event::Answered.new(:call_id => call_id)
        elsif node.xpath("//x:hangup", 'x' => rayo('1')).any?
          Connfu::Event::Hangup.new(:call_id => call_id)
        elsif node.xpath('//x:stop', 'x' => rayo('ext:complete:1')).first
          if recording_element = node.xpath('//x:recording', 'x' => rayo('record:complete:1')).first
            Connfu::Event::RecordingStopComplete.new(:call_id => call_id, :uri => recording_element.attributes['uri'].value)
          else
            Connfu::Event::StopComplete.new(:call_id => call_id)
          end
        elsif complete = node.xpath('//x:success', 'x' => tropo('ask:complete:1')).first
          captured_input = complete.xpath('//x:interpretation', 'x' => tropo('ask:complete:1')).first.inner_text
          Connfu::Event::AskComplete.new(:call_id => call_id, :captured_input => captured_input)
        elsif joined = node.xpath('//x:joined', 'x' => rayo('1')).first
          Connfu::Event::Joined.new(:call_id => call_id, :joined_call_id => joined.attributes['call-id'].value)
        elsif (results = node.xpath("//x:*", 'x' => tropo('transfer:complete:1'))).any?
          Connfu::TransferState.event_map[results.first.name.to_sym].new(:call_id => call_id)
        else
          raise "Stanza not recognised: #{node}"
        end
      end

      private

      def self.offer_params(node)
        presence_node = node.xpath('/presence').first
        p_attrs = presence_node.attributes
        offer = node.xpath('//x:offer', 'x' => rayo('1')).first
        from = offer.xpath('x:header[@name="From"]', 'x' => rayo('1')).first["value"]
        to = offer.xpath('x:header[@name="To"]', 'x' => rayo('1')).first["value"]
        {:presence_from => p_attrs['from'].value, :presence_to => p_attrs['to'].value,
         :from => from, :to => to}
      end
    end
  end
end
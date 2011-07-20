module Connfu
  module Ozone
    module IqBuilder

      def self.build_iq(to, from, command, attributes = {}, &block)
        iq = Blather::Stanza::Iq.new(:set, to)
        iq['from'] = from
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send "#{command}_", {"xmlns" => "urn:xmpp:ozone:1"}.merge(attributes), &block
        end

        iq
      end

    end
  end
end

module Connfu
  module Rayo
    module IqBuilder
      extend Connfu::Rayo::Namespacing

      def self.build_iq(to, from, command, attributes = {}, &block)
        iq = Blather::Stanza::Iq.new(:set, to)
        iq['from'] = from
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send "#{command}_", {"xmlns" => rayo("1")}.merge(attributes), &block
        end

        iq
      end

    end
  end
end

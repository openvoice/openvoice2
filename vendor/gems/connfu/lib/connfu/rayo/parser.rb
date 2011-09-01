module Connfu
  module Rayo
    module Parser
      def self.parse_event_from(node)
        Connfu::Event.parse(node) or raise "Stanza not recognised: #{node}"
      end
    end
  end
end
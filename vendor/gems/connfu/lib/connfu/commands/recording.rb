module Connfu
  module Commands
    module Recording
      class Start
        include Connfu::Commands::Base

        def to_iq
          build_iq "xmlns" => "urn:xmpp:ozone:record:1", "start-beep" => "true"
        end

        def command
          "record"
        end
      end

      class Stop
        include Connfu::Commands::Base

        def to
          super + "/" + @params[:ref_id]
        end

        def to_iq
          build_iq "xmlns" => "urn:xmpp:ozone:ext:1"
        end
      end
    end
  end
end
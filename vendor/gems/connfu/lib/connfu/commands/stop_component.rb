module Connfu
  module Commands
    module StopComponent
      def component_id
        @params[:ref_id]
      end
      
      def component_jid
        call_jid + "/" + component_id
      end

      def recipient_jid
        component_jid
      end

      def to_iq
        build_iq "xmlns" => rayo("ext:1")
      end
    end
  end
end
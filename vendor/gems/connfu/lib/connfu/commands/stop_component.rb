module Connfu
  module Commands
    module StopComponent
      def to
        super + "/" + @params[:ref_id]
      end

      def to_iq
        build_iq "xmlns" => rayo("ext:1")
      end
    end
  end
end
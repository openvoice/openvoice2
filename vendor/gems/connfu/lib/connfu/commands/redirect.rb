module Connfu
  module Commands
    class Redirect
      include Base

      def to_iq
        build_iq 'to' => @params[:redirect_to]
      end
    end
  end
end
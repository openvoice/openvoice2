module Connfu
  module Commands
    class Transfer
      include Base

      def to_iq
        attributes = {"xmlns" => tropo('transfer:1')}
        attributes[:timeout] = @params[:timeout] if @params[:timeout]

        build_iq attributes do |xml|
          @params[:transfer_to].each { |t| xml.to t }
        end
      end
    end
  end
end
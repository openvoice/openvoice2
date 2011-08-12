module Connfu
  module Commands
    class NestedJoin
      include Base

      def command
        "dial"
      end

      def dial_to
        @params[:dial_to]
      end

      def dial_from
        @params[:dial_from]
      end

      def build_iq
        super(:to => dial_to, :from => dial_from, "xmlns" => rayo('1')) do |xml|
          xml.join_("xmlns" => rayo('join:1'), :direction => "duplex", :media => "bridge", :"call-id" => @params[:call_id])
        end
      end
    end
  end
end
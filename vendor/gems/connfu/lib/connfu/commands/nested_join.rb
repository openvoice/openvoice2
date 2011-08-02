module Connfu
  module Commands
    class NestedJoin
      include Base

      def command
        "dial"
      end

      def to_iq
        build_iq(:to => @params[:dial_to], :from => @params[:dial_from], "xmlns" => rayo('1')) do |xml|
          xml.join_("xmlns" => rayo('join:1'), :direction => "duplex", :media => "bridge", :"call-id" => @params[:call_id])
        end
      end
    end
  end
end
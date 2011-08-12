module Connfu
  module Commands
    class Join
      include Base

      def build_iq
        oc_iq = Blather::Stanza::Iq.new(:set, call_jid)
        oc_iq.from = client_jid
        Nokogiri::XML::Builder.with(oc_iq) do |xml|
          xml.join_("xmlns" => rayo('1'), :direction => "duplex", :media => "bridge", :"call-id" => @params[:call_id])
        end
        
        oc_iq
      end
    end
  end
end
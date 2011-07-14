module Connfu
  module Commands
    class Dial
      include Base

      def to_iq
        oc_iq = Blather::Stanza::Iq.new(:set, Connfu.connection.jid.domain)
        oc_iq.from = Connfu.connection.jid.to_s
        Nokogiri::XML::Builder.with(oc_iq) do |xml|
          xml.dial_(:to => @params[:to], :from => @params[:from], "xmlns" => "urn:xmpp:ozone:1")
        end

        l.debug oc_iq
        oc_iq
      end
    end
  end
end
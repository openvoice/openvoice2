module Connfu
  module Commands
    class Dial
      include Base

      def headers
        @params[:headers] || {}
      end
      
      def from
        @params[:from]
      end

      def to_iq
        oc_iq = Blather::Stanza::Iq.new(:set, @params[:rayo_host])
        oc_iq.from = client_jid
        Nokogiri::XML::Builder.with(oc_iq) do |xml|
          xml.dial_(:to => @params[:to], :from => from, "xmlns" => rayo("1")) do
            headers.each do |key, val|
              xml.header_(:name => key, :value => val)
            end
          end
        end

        oc_iq
      end
    end
  end
end
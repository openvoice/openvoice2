module Connfu
  module Commands
    class Say
      include Base

      def text
        @params[:text]
      end

      def to_iq
        build_iq "xmlns" => "urn:xmpp:ozone:say:1" do |xml|
          unless text.match(/^http:\/\/.*(.mp3|.wav)$/).nil?
            xml.audio('src' => text)
          else
            xml.text text
          end
        end
      end
    end
  end
end
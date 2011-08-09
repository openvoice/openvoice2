module Connfu
  module Commands
    module Base
      include Connfu::Logging
      include Connfu::Rayo::Namespacing

      def initialize(params)
        @params = params
      end

      def ==(other)
        other.kind_of?(self.class) && other.params == @params
      end

      def id
        to_iq.attributes['id'].to_s
      end

      def call_jid
        @params[:call_jid]
      end

      def client_jid
        @params[:client_jid]
      end

      def command
        self.class.name.split("::").last.downcase
      end

      def recipient_jid
        call_jid
      end

      def to_iq
        build_iq
      end

      protected

      def params
        @params
      end

      def build_iq(attributes = {}, &block)
        @iq ||= Connfu::Rayo::IqBuilder.build_iq(recipient_jid, client_jid, command, attributes, &block)
      end
    end
  end
end
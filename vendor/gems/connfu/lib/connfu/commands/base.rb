module Connfu
  module Commands
    module Base
      def initialize(params)
        @params = params
      end

      def ==(other)
        other.kind_of?(self.class) && other.params == @params
      end

      def to
        @params[:to]
      end

      def from
        @params[:from]
      end

      def command
        self.class.name.split("::").last.downcase
      end

      def to_iq
        build_iq
      end

      protected

      def params
        @params
      end

      def build_iq(attributes = {}, &block)
        Connfu::Ozone::IqBuilder.build_iq(to, from, command, attributes, &block)
      end
    end
  end
end
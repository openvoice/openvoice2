require "forwardable"

module Connfu
  module Queue
    autoload :InProcess, 'connfu/queue/in_process'
    autoload :Worker, 'connfu/queue/worker'

    class << self
      attr_writer :implementation

      def implementation
        @implementation ||= InProcess.new
      end

      extend Forwardable

      def_delegators :implementation, :clear, :enqueue, :reserve, :size
    end
  end
end
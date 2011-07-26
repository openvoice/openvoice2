module Connfu
  module Jobs
    class Dial
      include Connfu::Logging

      class << self
        def queue
          "dials"
        end

        def perform(*args)
          logger.debug "Dialing #{args.inspect}"
          Connfu.connection.send_command Connfu::Commands::Dial.new(:to => args.first["to"], :from =>args.first["from"])
        end
      end
    end
  end
end


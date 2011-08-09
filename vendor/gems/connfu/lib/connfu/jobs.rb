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
          Connfu.connection.send_command Connfu::Commands::Dial.new(:to => args.first["to"], :from =>args.first["from"], :client_jid => Connfu.connection.jid.to_s, :rayo_host => Connfu.connection.jid.domain)
        end
      end
    end
  end
end


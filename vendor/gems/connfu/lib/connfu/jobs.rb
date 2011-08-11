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
          options = {:to => args.first["to"], :from =>args.first["from"],
                     :client_jid => Connfu.connection.jid.to_s,
                     :rayo_host => Connfu.connection.jid.domain}
          options.merge!(:headers => args.first["headers"]) if args.first["headers"]
          Connfu.connection.send_command Connfu::Commands::Dial.new(options)
        end
      end
    end
  end
end


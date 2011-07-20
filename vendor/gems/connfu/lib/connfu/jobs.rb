module Connfu
  module Jobs
    class Dial
      class << self
        def queue
          "dials"
        end

        def perform(*args)
          l.debug "Dialing #{args.inspect}"
          Connfu.adaptor.send_command Connfu::Commands::Dial.new(:to => args.first["to"], :from =>args.first["from"])
        end
      end
    end
  end
end


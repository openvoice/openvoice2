module Connfu
  module App
    def self.dial(options)
      Resque.enqueue(Jobs::Dial, options)
    end
  end

  module Jobs
    class Dial
      class << self
        def queue
          "dials"
        end

        def perform(*args)
          p "Dialing #{args.inspect}"
          Connfu.adaptor.send_command Connfu::Commands::Dial.new(:to => args.first["to"], :from =>args.first["from"])
        end
      end
    end
  end
end


module Connfu
  class ConnectionAdaptor
    def initialize(connection)
      @connection = connection
    end

    def send_command(command)
      iq = command.to_iq
      l.debug iq
      @connection.write iq
    end
  end
end
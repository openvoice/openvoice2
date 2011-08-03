module Connfu
  module Commands
    class Stop
      include Connfu::Commands::Base
      include Connfu::Commands::StopComponent
    end
  end
end
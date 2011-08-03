module Connfu::Commands
  autoload :Base, 'connfu/commands/base'
  autoload :StopComponent, 'connfu/commands/stop_component'

  Dir[File.expand_path("../commands/**/*.rb", __FILE__)].each do |f|
    require f
  end
end
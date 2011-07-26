module Connfu::Commands
  autoload :Base, 'connfu/commands/base'

  Dir[File.expand_path("../commands/**/*.rb", __FILE__)].each do |f|
    require f
  end
end
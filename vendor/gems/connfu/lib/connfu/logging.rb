require 'connfu'
require 'logger'

module Connfu::Logging
  def self.included(base)
    base.extend ClassMethods
  end

  def logger
    Connfu.logger
  end

  module ClassMethods
    def logger
      Connfu.logger
    end
  end
end
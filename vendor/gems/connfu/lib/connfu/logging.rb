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

  class IOLogger < ::Logger
    def initialize(*args)
      super
      self.formatter = proc { |severity, datetime, progname, msg| msg + "\n" }
      @last_message_state = nil
    end

    [:sent, :received].each do |kind|
      define_method(kind) do |data|
        debug "#{kind.upcase}:" unless @last_message_state == kind
        @last_message_state = kind
        info data.to_s
      end
    end
  end
end
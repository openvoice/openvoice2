require 'logger'

class Log
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end

module Kernel
  def l
    Log.logger
  end
end
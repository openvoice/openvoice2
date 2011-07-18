require 'continuation' if RUBY_VERSION == "1.9.2"

module Connfu
  module Continuation
    def start(*args, &block)
      if block_given?
        continue_with block
      else
        continue_with lambda {|result| run(*args)}
      end
    end

    def continue(result = nil)
      if continuation = @continuation
        @continuation = nil
        continue_with(continuation, result)
      end
    end

    def continue_with(next_step, result = nil)
      callcc do |caller|
        @latest_caller = caller
        catch :waiting do
          next_step.call(result)
        end
        @latest_caller.call
      end
    end

    def wait
      callcc do |cc|
        @continuation = cc
        throw :waiting
      end
    end
  end
end

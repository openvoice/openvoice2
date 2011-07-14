module Connfu
  class EventProcessor
    def initialize(handler_class)
      @handler_class = handler_class
    end

    def handle_event(event)
      if event && event.respond_to?(:call_id) && h = handler_for(event)
        h.handle_event(event)
      end
      remove_finished_handlers
    end

    private

    def handler_for(event)
      if event.is_a?(Connfu::Event::Offer)
        handlers[event.call_id] = @handler_class.new(:from => event.presence_from, :to => event.presence_to)
      elsif event.is_a?(Connfu::Event::Ringing)
        handlers[event.call_id] = @handler_class.new(:from => event.presence_from, :to => event.presence_to)
      else
        handlers[event.call_id]
      end
    end

    def handlers
      @handlers ||= {}
    end

    def remove_finished_handlers
      handlers.keys.each do |call_id|
        h = handlers[call_id]
        if h.finished?
          l.debug "Removing handler for call_id #{call_id}"
          handlers.delete(call_id)
        end
      end
    end
  end
end
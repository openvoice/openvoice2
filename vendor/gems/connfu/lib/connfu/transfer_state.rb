module Connfu
  class TransferState
    def self.rejected
      new(:rejected)
    end

    def self.busy
      new(:busy)
    end

    def self.answered
      new(:answered)
    end

    def self.timeout
      new(:timeout)
    end

    def initialize(state)
      @state = state
    end

    def rejected?
      @state == :rejected
    end

    def busy?
      @state == :busy
    end

    def answered?
      @state == :answered
    end

    def timeout?
      @state == :timeout
    end

    protected

    def self.event_map
      {
          :success => Connfu::Event::TransferSuccess,
          :timeout => Connfu::Event::TransferTimeout,
          :reject => Connfu::Event::TransferRejected,
          :busy => Connfu::Event::TransferBusy,
      }
    end
  end
end
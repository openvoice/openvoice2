require "connfu"

module Jobs
  class RecordGreeting
    include Connfu::Dsl

    def self.queue
      Connfu::Jobs::Dial.queue
    end

    def self.perform(openvoice_number, endpoint_address)
      dial :from => openvoice_number, :to => endpoint_address do |call|
        call.on_answer do
          say 'please record a greeting'
          record_for 10
        end
      end
    end
  end
end
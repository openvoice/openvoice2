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

          recordings = record_for 10

          p "****** OVNUMBER: " + openvoice_number

          account = Account.find_by_username(openvoice_number.match(/^sip:(.*)@.*/)[1])
          account.update_attribute(:greeting_path, recordings.first)


        end
      end
    end
  end
end
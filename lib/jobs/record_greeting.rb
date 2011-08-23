require "connfu"
require "open-uri"

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
          account = Account.find_by_username(openvoice_number.match(/^sip:(.*)@.*/)[1])

          original_file = recordings.first
          asset_path = open("http://173.255.241.49:4857/#{original_file.gsub('file://', '')}").read
          account.update_attribute(:greeting_path, asset_path)
        end
      end
    end
  end
end
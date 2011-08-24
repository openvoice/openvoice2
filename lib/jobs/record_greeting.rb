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
          account = Account.find_by_username(openvoice_number.match(/^sip:(.*)@.*/)[1])
          original_file = recordings.first
          asset_handler_path = Rails.configuration.asset_handler_server + original_file.gsub('file:', '')

          begin
            greeting_asset_path = open(asset_handler_path).read
            account.update_attribute(:greeting_path, greeting_asset_path)
          rescue Errno::ECONNREFUSED, OpenURI::HTTPError => e
            logger.warn "Could not connect to AssetHandler"
          end
        end
      end
    end
  end
end
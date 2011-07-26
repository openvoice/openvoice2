require 'connfu'

Connfu.config.uri = ENV['CONNFU_JABBER_URI']

Connfu.start do
  on :offer do |call|
    if account = Account.find_by_username(call.to[:username])
      answer
      say 'please wait while we transfer your call'
      result = transfer *account.endpoints.map(&:address)
      puts "The call was answered, and has finished" if result.answered?
    end
  end
end

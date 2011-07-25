module AuthHelpers
  def login(account)
    session[:account_id] = account.id
  end
end

RSpec.configure do |config|
  config.include AuthHelpers
end
class ApplicationController < ActionController::Base
  protect_from_forgery

  def login(account)
    session[:account_id] = account.id
    self.current_account = account
  end

  def current_account=(account)
    @current_account = account
  end

  def current_account
    @current_account ||= Account.find(session[:account_id])
  end
end

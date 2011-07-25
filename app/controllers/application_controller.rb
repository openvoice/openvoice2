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
    @current_account ||= Account.find_by_id(session[:account_id])
  end

  def authenticate
    unless current_account
      redirect_to new_session_path
    end
  end

end
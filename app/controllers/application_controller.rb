require "jobs"
require "connfu"

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :logged_in?, :current_account

  def login(account)
    self.current_account = account
  end

  def logout
    self.current_account = nil
  end

  def current_account=(account)
    @current_account = account
    session[:account_id] = account ? account.id : nil
  end

  def current_account
    @current_account ||= Account.find_by_id(session[:account_id])
  end

  def authenticate
    redirect_to new_session_path unless current_account
  end

  def logged_in?
    current_account.present?
  end

end
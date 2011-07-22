class SessionsController < ApplicationController
  def new
  end

  def create
    if account = Account.find_by_email(params[:email]).try(:authenticate, params[:password])
      login(account)
      flash[:notice] = "Logged in successfully"
      redirect_to account
    else
      flash[:error] = "Email or Password was incorrect"
      redirect_to new_session_path
    end
  end
end
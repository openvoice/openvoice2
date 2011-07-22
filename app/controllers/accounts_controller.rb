class AccountsController < ApplicationController
  def new
    @account = Account.new
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      redirect_to root_path, :notice => "Sign up was successful"
    else
      flash[:error] = "There was an error creating your account"
      render :new
    end
  end
end
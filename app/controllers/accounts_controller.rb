class AccountsController < ApplicationController
  def new
    @account = Account.new
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      redirect_to root_path, :notice => "Your account has been created successfully"
    else
      flash[:error] = "There was an error creating your account"
      render :new
    end
  end

  def show
  end
end
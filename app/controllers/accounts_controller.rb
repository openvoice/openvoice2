class AccountsController < ApplicationController
  before_filter :authenticate, :only => [:show]

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
    @account = Account.find_by_id(params[:id])
    unless current_account == @account
      flash[:error] = "You do not have permission to view this page"
      redirect_to root_path
    end
  end
end
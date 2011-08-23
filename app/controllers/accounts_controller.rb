class AccountsController < ApplicationController
  before_filter :authenticate, :except => [:new, :create]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      login(@account)
      redirect_to @account, :notice => "Your account has been created successfully"
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

  def update
    @account = Account.find_by_id(params[:id])
    if @account.update_attributes(params[:account])
      redirect_to @account, :notice => "Account updated"
    end
  end
end
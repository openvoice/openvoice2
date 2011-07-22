class AccountsController < ApplicationController
  def new
    @account = Account.new
  end

  def create
    @account = Account.create!(params[:account])
    redirect_to root_path, :notice => "Sign up was successful"
  end
end
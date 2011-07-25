class EndpointsController < ApplicationController
  before_filter :authenticate

  def new
    @endpoint = current_account.endpoints.new
  end

  def create
    @endpoint = current_account.endpoints.create(params[:endpoint])
    flash[:notice] = "The endpoint has been added to your account"
    redirect_to current_account
  end

end

class EndpointsController < ApplicationController
  before_filter :authenticate

  def new
    @endpoint = current_account.endpoints.new
  end

  def create
    @endpoint = current_account.endpoints.new(params[:endpoint])
    if @endpoint.save
      flash[:notice] = "The endpoint has been added to your account"
      redirect_to current_account
    else
      flash[:error] = "The endpoint couldn't be added to your account"
      render "new"
    end
  end

end

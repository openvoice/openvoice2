require "jobs"
require "connfu"

class CallsController < ApplicationController
  before_filter :authenticate
  before_filter :load_endpoint

  def new
    @endpoint = current_account.endpoints.find(params[:endpoint_id])
    @call = @endpoint.calls.build
  end

  def create
    @call = @endpoint.calls.build(params[:call])
    if @call.save
      Connfu::Queue.enqueue(Jobs::OutgoingCall, @call.id)
      redirect_to endpoint_call_path(@endpoint, @call)
    else
      render :new
    end
  end

  def show

  end

  protected

  def load_endpoint
    @endpoint = current_account.endpoints.find(params[:endpoint_id])
  end
end
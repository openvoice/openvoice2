class CallsController < ApplicationController
  before_filter :authenticate
  before_filter :load_endpoint, :except => [:show]

  respond_to :html
  respond_to :json, :only => [:show]

  def new
    @call = @endpoint.calls.build
  end

  def create
    @call = current_account.calls.build(params[:call].merge(:endpoint => @endpoint))
    if @call.save
      Connfu::Queue.enqueue(Jobs::OutgoingCall, @call.id)
      redirect_to call_path(@call)
    else
      render :new
    end
  end

  def show
    @call = current_account.calls.find(params[:id])
    respond_with @call do |format|
      format.json { render :text => @call.to_json(:methods => :display_state) }
    end
  end

  protected

  def load_endpoint
    @endpoint = current_account.endpoints.find(params[:endpoint_id])
  end
end
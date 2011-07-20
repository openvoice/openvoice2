class DialsController < ApplicationController
  def new

  end

  def create
    dsl = Class.new do
      include Connfu::Dsl
    end
    dsl.dial(:to => params[:to], :from => params[:from])
    flash[:notice] = "Dialed #{params[:to]} successfully"
    redirect_to new_dial_path
  end
end
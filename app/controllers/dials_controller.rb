require "jobs"
require "connfu"
require "connfu/queue/resque"

class DialsController < ApplicationController
  def new

  end

  def create
    Connfu::Queue.enqueue(Jobs::OutgoingCall, params[:from], params[:to])
    flash[:notice] = "Dialed #{params[:to]} successfully"
    redirect_to new_dial_path
  end
end
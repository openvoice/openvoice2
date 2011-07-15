class DialsController < ApplicationController
  def new

  end

  def create
    Connfu::App.dial(:to => params[:to], :from => params[:from]) do |c|
      c.on_ringing do
        update_status "The phone is ringing!"
      end
      c.on_answer do
        update_status "The phone was answered!"

        say "Though I am but a robot, my love for you is real."
        hangup
      end
      c.on_hangup do
        update_status "The phone was hung up"
      end
    end
    flash[:notice] = "Dialed #{params[:to]} successfully"
    redirect_to new_dial_path
  end
end
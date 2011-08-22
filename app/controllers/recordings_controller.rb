class RecordingsController < ApplicationController
  before_filter :authenticate

  def create
    Connfu::Queue.enqueue(Jobs::RecordGreeting, current_account.number, current_account.endpoints.first.address)
    render :nothing => true
  end

end
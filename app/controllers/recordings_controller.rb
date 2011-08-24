class RecordingsController < ApplicationController
  before_filter :authenticate

  def create
    Connfu::Queue.enqueue(Jobs::RecordGreeting, current_account.address, current_account.endpoints.first.address)
    redirect_to current_account
  end
end
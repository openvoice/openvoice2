class HomeController < ApplicationController
  before_filter :authenticate, :only => [:show]
  def show
    redirect_to account_path(current_account)
  end
end
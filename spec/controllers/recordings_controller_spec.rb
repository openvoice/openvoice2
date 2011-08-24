require 'spec_helper'

describe RecordingsController do
  describe "when not logged in" do
    describe "POST to create" do
      before do
        post :create
      end

      it "should redirect to login page" do
        response.should redirect_to(new_session_path)
      end
    end
  end

  describe "when logged in" do
    before do
      ResqueSpec.reset!

      @account = Factory(:account)
      @controller.stubs(:current_account).returns(@account)
      @endpoint = Factory(:endpoint, :account => @account)
    end

    describe "POST to create" do
      it "should queue record greeting job" do
        Connfu::Queue.implementation = ::Resque
        post :create

        Jobs::RecordGreeting.should have_queued(@account.address, @account.endpoints.first.address)
      end

      it "should re-render account page" do
        post :create

        response.should redirect_to(account_path(@account))
      end
    end
  end
end
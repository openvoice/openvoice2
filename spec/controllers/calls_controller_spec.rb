require 'spec_helper'

describe CallsController do
  describe "when not logged in" do
    before do
      @endpoint = Factory(:endpoint, :account => Factory(:account))
    end

    describe "GET to new" do
      before do
        get :new, :endpoint_id => @endpoint.id
      end
      it "should redirect to login page" do
        response.should redirect_to(new_session_path)
      end
    end

    describe "POST to create" do
      before do
        post :create, :endpoint_id => @endpoint.id
      end
      it "should redirect to login page" do
        response.should redirect_to(new_session_path)
      end
    end

    describe "GET to show" do
      before do
        call = Factory(:call, :endpoint => @endpoint)
        get :show, :id => call.id, :endpoint_id => @endpoint.id
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
      it "should create the call and queue the outgoing call" do
        Connfu::Queue.implementation = ::Resque
        post :create, :endpoint_id => @endpoint.id, :call => {:recipient_address => 'recipient-address'}

        @endpoint.calls.count.should eq 1
        @endpoint.calls.last.recipient_address.should eq "recipient-address"

        Jobs::OutgoingCall.should have_queued(@endpoint.calls.last.id)
      end

      it "should redirect to the new call" do
        Connfu::Queue.stubs(:enqueue)

        post :create, :endpoint_id => @endpoint.id, :call => {:recipient_address => 'recipient-address'}

        assert_redirected_to endpoint_call_path(@endpoint, @endpoint.calls.last)
      end
    end
  end
end
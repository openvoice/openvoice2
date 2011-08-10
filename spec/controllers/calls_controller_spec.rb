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
end
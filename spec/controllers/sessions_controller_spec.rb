require 'spec_helper'

describe SessionsController do

  describe "GET to new" do
    before do
      get :new
    end

    it "should render the login page" do
      response.should render_template("sessions/new")
    end
  end

  describe "POST to create" do
    describe "with valid created account details" do
      before do
        @account = Factory(:account)
        post :create, :email => @account.email, :password => @account.password
      end

      it "should login the account" do
        session[:account_id].should_not be_nil
        session[:account_id].should eq @account.id
      end
    end

    describe "with a user that does not exist" do
      before do
        post :create, :email => "someone@example.com", :password => "password"
      end

      it "should not login anyone" do
        session[:account_id].should be_nil
      end

      it "should redirect user back to the login page" do
        response.should redirect_to(new_session_path)
      end

      it "should set an error message" do
        flash[:error] = "Email or Password was incorrect"
      end
    end
  end
end
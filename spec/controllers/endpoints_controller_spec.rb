require 'spec_helper'

describe EndpointsController do
  describe "when not logged in" do
    before do
      @endpoint = Factory(:endpoint, :account => Factory(:account))
    end

    describe "GET to new" do
      before do
        get :new
      end
      it "should redirect to login page" do
        response.should redirect_to(new_session_path)
      end
    end

    describe "POST to create" do
      before do
        post :create, :endpoint => Factory.attributes_for(:endpoint)
      end
      it "should redirect to login page" do
        response.should redirect_to(new_session_path)
      end
    end

    describe "DELETE to destroy" do
      before do
        delete :destroy, :id =>@endpoint.to_param
      end
      it "should redirect to login page" do
        response.should redirect_to(new_session_path)
      end
    end
  end


  describe "when logged in" do
    before do
      @account = Factory(:account)
      login(@account)
    end

    describe "GET to new" do
      before do
        get :new
      end

      it "should render the correct template" do
        response.should render_template("endpoints/new")
      end

      it "should assign an endpoint" do
        assigns[:endpoint].should_not be_nil
      end
    end

    describe "POST to create" do
      describe "with valid attributes" do
        before do
          post :create, :endpoint => {:address => "sip:user@example.com"}
        end

        it "should create the endpoint for the logged in account" do
          @account.endpoints.count.should eq 1
        end

        it "should redirect to the account page" do
          response.should redirect_to account_path(@account)
        end

        it "should notify the user that the endpoint has been added" do
          flash[:notice].should eq "The endpoint has been added to your account"
        end
      end

      describe "with missing attributes" do
        before do
          post :create, :endpoint => {}
        end

        it "should not create an endpoint" do
          @account.endpoints.count.should eq 0
        end

        it "should render the new endpoint template" do
          response.should render_template("endpoints/new")
        end

        it "should tell the user that the endpoint couldn't be created" do
          flash[:error].should eq "The endpoint couldn't be added to your account"
        end
      end
    end

    describe "DELETE to destroy" do
      before do
        @endpoint = Factory(:endpoint, :account => Factory(:account))
        delete :destroy, :id => @endpoint.to_param
      end

      it "should remove the endpoint" do
        Endpoint.exists?(@endpoint.id).should be_false
      end

      it "should redirect to the accounts page" do
        response.should redirect_to account_path(@account)
      end

      it "should notify the user that the endpoint was deleted" do
        flash[:notice].should eq "Endpoint successfully removed"
      end
    end

    describe "DELETE to destroy with an endpoint that doesn't exist'" do
      before do
        @endpoint = Factory(:endpoint, :account => Factory(:account))
        delete :destroy, :id => "does-not-exist"
      end

      it "should not remove any endpoints" do
        Endpoint.exists?(@endpoint.id).should be_true
      end

      it "should redirect to the accounts page" do
        response.should redirect_to account_path(@account)
      end

      it "should notify the user no endpoint could be found" do
        flash[:error].should eq "No endpoint could be found"
      end
    end
  end
end

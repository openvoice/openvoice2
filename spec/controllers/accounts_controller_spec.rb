require 'spec_helper'

describe AccountsController do

  describe "GET to new" do
    before do
      get :new
    end

    it "should render the new account page" do
      response.should render_template("accounts/new")
    end

    it "should assign an account" do
      assigns[:account].should_not be_nil
    end
  end

  describe "POST to create" do
    describe "with valid attributes" do
      before do
        post :create, :account => Factory.attributes_for(:account)
      end

      it "should create an account" do
        Account.count.should eq 1
      end
    end

    describe "with a missing attribute" do
      before do
        post :create, :account => Factory.attributes_for(:account, :email => nil)
      end

      it "should not create any accounts" do
        Account.count.should eq 0
      end

      it "should render the new account page" do
        response.should render_template("accounts/new")
      end

      it "should set an error notice" do
        flash[:error].should_not be_nil
        flash[:error].should eq "There was an error creating your account"
      end
    end
  end

  describe "When not logged in" do
    describe "GET to show" do
      before do
        get :show, :id => "1"
      end

      it "should redirect to the login page" do
        response.should redirect_to new_session_path
      end
    end
  end

  describe "When logged in with an account" do
    before do
      @account = Factory(:account)
      login @account
    end

    describe "GET to show" do
      before do
        get :show, :id => @account.to_param
      end

      it "should render show template" do
        response.should render_template("accounts/show")
      end

      it "should find and assign the account for view template" do
        assigns[:account].should eq @account
      end
    end

    describe "GET to show for a different account" do
      before do
        get :show, :id => Factory(:account).to_param
      end

      it "should redirect to the root path" do
        response.should redirect_to root_path
      end

      it "should tell the user that they can not view this account" do
        flash[:error].should eq "You do not have permission to view this page"
      end
    end
  end
end
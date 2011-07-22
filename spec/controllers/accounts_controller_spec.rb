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
        post :create, :account => {:email => "me@example.com", :password => "password", :password_confirmation => "password"}
      end

      it "should create an account" do
        Account.count.should eq 1
      end
    end

    describe "with a missing attribute" do
      before do
        post :create, :account => {:password => "password", :password_confirmation => "password"}
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
end
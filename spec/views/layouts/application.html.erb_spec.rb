require 'spec_helper'

describe 'layouts/application.html.erb' do
  
  context "a logged in user" do
    
    before do
      @account = Factory(:account)
      view.stubs(:logged_in?).returns(true)
      view.stubs(:current_account).returns(@account)
    end
  
    it 'should display the openvoice number' do
      @account.number = Factory(:phone_number)
      render
      assert_select '#ov-number', :text => /#{@account.number}/
    end
  
    it "should not display the openvoice number if the user doesn't have one" do
      @account.number = nil
      render
      assert_select '#ov-number', :count => 0
    end
    
  end
  
end
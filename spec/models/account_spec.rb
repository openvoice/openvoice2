require 'spec_helper'

describe Account do
  describe "(any instance)" do
    subject { Factory.build(:account) }

    it "is valid with an email, username and password" do
      subject.should be_valid
    end

    it "is invalid without an email" do
      subject.email = nil
      subject.should_not be_valid
    end

    it "is invalid with a duplicate email" do
      another_account = Factory.create(:account, :email => "existing-email")
      subject.email = "existing-email"
      subject.should_not be_valid
    end
    
    it "is invalid with a duplicate number" do
      another_account = Factory.create(:account, :number => 'existing-number')
      subject.number = 'existing-number'
      subject.should_not be_valid
    end

    it "is invalid without an username" do
      subject.username = nil
      subject.should_not be_valid
    end

    it "is invalid with a duplicate username" do
      another_account = Factory.create(:account, :username => "existing-username")
      subject.username = "existing-username"
      subject.should_not be_valid
    end

    it "is invalid without a password_digest" do
      subject.password_digest = nil
      subject.should_not be_valid
    end

    it "is invalid if password and confirmation don't match" do
      subject.password = 'password'
      subject.password_confirmation = 'different'
      subject.should_not be_valid
    end

    describe "when Connfu host is configured" do
      before do
        Connfu.stubs(:config).returns(stub("config", :host => "127.0.0.1"))
      end

      it "should have an address on the Prism server" do
        subject.address.should eq "sip:#{subject.username}@127.0.0.1"
      end
    end
  end
end
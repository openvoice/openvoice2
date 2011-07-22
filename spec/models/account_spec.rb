require 'spec_helper'

describe Account do
  describe "(any instance)" do
    subject { Account.new(:email => 'anything', :password => 'anything') }

    it "is valid with an email and password" do
      subject.should be_valid
    end

    it "is invalid without an email" do
      subject.email = nil
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
  end
end
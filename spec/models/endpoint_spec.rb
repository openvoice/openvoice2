require 'spec_helper'

describe Endpoint do
  describe "(any instance)" do
    subject { Factory.build(:endpoint, :account => Factory(:account)) }

    it "is valid with an account id and address" do
      subject.should be_valid
    end

    it "is invalid without an address" do
      subject.address = nil
      subject.should_not be_valid
    end

    it "is invalid without an account id" do
      subject.account_id = nil
      subject.should_not be_valid
    end
  end
end

require "spec_helper"

describe "two simultaneous offers" do

  testing_dsl do
    on :offer do |call|
      answer
      say 'this is the first say'
      say 'this is the second say'
    end
  end

  before :each do
    @first_server_address = "foo@server.whatever"
    @second_server_address = "bar@server.whatever"
    @foo_address = "foo@clientfoo.com"
    @bar_address = "bar@clientbar.com"
  end

  it "should handle each call independently" do
    incoming :offer_presence, @first_server_address, @foo_address
    incoming :result_iq, "foo"
    incoming :result_iq, "foo"

    incoming :offer_presence, @second_server_address, @bar_address
    incoming :result_iq, "bar"
    incoming :result_iq, "bar"

    incoming :say_complete_success, "bar"
    Connfu.adaptor.commands = []
    incoming :say_complete_success, "foo"

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'this is the second say', :to => @first_server_address, :from => @foo_address)
  end

end

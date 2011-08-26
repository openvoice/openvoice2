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
    @first_call_jid = "call-id-1@server.whatever"
    @second_call_jid = "call-id-2@server.whatever"
    @foo_address = "foo@clientfoo.com"
    @bar_address = "bar@clientbar.com"
  end

  it "should handle each call independently" do
    incoming :offer_presence, @first_call_jid, @foo_address
    incoming :say_result_iq, @first_call_jid
    incoming :say_result_iq, @first_call_jid

    incoming :offer_presence, @second_call_jid, @bar_address
    incoming :say_result_iq, @second_call_jid
    incoming :say_result_iq, @second_call_jid

    incoming :say_success_presence, @second_call_jid
    Connfu.connection.commands = []
    incoming :say_success_presence, @first_call_jid

    last_command.should == Connfu::Commands::Say.new(:text => 'this is the second say', :call_jid => @first_call_jid, :client_jid => @foo_address)
  end

end

require "spec_helper"

describe Connfu::Commands::Base do

  class Connfu::Commands::Generic
    include Connfu::Commands::Base
  end

  it "returns the id from the generated XMPP stanza" do
    Connfu::Rayo::IqBuilder.stub!(:build_iq).and_return(stub(:attributes => { "id" => "command-id" }))
    command = Connfu::Commands::Generic.new({})
    command.id.should == "command-id"
  end

  it "should return the same id when called multiple times" do
    Connfu::Rayo::IqBuilder.stub!(:build_iq).and_return(
      stub(:attributes => { "id" => "command-id-1" }),
      stub(:attributes => { "id" => "command-id-2" })
    )
    command = Connfu::Commands::Generic.new({})
    2.times { command.id.should == "command-id-1" }
  end

end
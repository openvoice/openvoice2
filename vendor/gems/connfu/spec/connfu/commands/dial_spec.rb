require "spec_helper"

describe Connfu::Commands::Dial do

  describe "generating XMPP iq" do
    describe "for the Dial command" do
      before do
        @connection = TestConnection.new
        Connfu.stub(:connection).and_return(@connection)
      end

      subject do
        Connfu::Commands::Dial.new(
          :to => 'zlu@iptel.org',
          :from => 'admin@openvoice.org'
        ).to_iq
      end

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should contain the 'to' address in the iq" do
        subject.xpath("/iq").first.attributes["to"].value.should eq 'openvoice.org'
      end

      it "should contain the 'from' address in the iq" do
        subject.xpath("/iq").first.attributes["from"].value.should eq 'zlu@openvoice.org/1'
      end

      describe 'dial node' do
        it 'should exist' do
          subject.xpath("//x:dial", "x" => rayo('1')).size.should eq 1
        end

        it 'should have correct to and from attributes' do
          node = subject.xpath("//x:dial", "x" => rayo('1')).first
          node.attributes['to'].value.should eq 'zlu@iptel.org'
          node.attributes['from'].value.should eq 'admin@openvoice.org'
        end
      end
    end

    describe "for the Dial command with custom headers" do
      before do
        @connection = TestConnection.new
        Connfu.stub(:connection).and_return(@connection)
      end

      subject do
        Connfu::Commands::Dial.new(
          :to => 'zlu@iptel.org',
          :from => 'admin@openvoice.org',
          :headers => {
            "x-jaja-charging" => '123'
        }).to_iq
      end

      describe 'dial headers' do
        it 'should exist' do
          subject.xpath("//x:dial/x:header", "x" => rayo('1')).size.should eq 1
        end

        it 'should have the correct attributes' do
          node = subject.xpath("//x:dial/x:header", "x" => rayo('1')).first
          node.attributes['name'].value.should eq "x-jaja-charging"
          node.attributes['value'].value.should eq "123"
        end
      end
    end
  end
end
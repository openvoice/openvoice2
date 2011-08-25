require 'spec_helper'

describe Jobs::RecordGreeting do

  before do
    setup_connfu(handler_class = nil)
  end

  describe "Record greeting for OpenVoice account" do
    before do
      @account = Factory(:account, :username => "my-openvoice-username")
      @endpoint = "sip:endpoint-to-call@example.com"
      Jobs::RecordGreeting.perform(@account.address, @endpoint)
    end

    it "should issue a dial command" do
      last_command.should be_instance_of Connfu::Commands::Dial
    end

    it 'should dial from the openvoice2 address' do
      last_command.from.should == "sip:my-openvoice-username@#{Connfu.config.host}"
    end

    it "should dial the openvoice user's endpoint address" do
      last_command.to.should == "sip:endpoint-to-call@example.com"
    end

    describe "when the endpoing answers" do
      before do
        @call_jid = "call-id@openvoice.org"
        @client_jid = "usera@#{Connfu.config.host}"
        incoming :dial_result_iq, "call-id", last_command.id
        incoming :ringing_presence, @call_jid, @client_jid
        incoming :answered_presence, @call_jid
      end

      it "should say to user 'please record a greeting'" do
        last_command.should be_instance_of(Connfu::Commands::Say)
        last_command.text.should == 'please record a greeting'
      end

      describe "recording the user's greeting" do
        before do
          incoming :result_iq, @call_jid
          incoming :say_success_presence, @call_jid
        end

        it "should issue record command" do
          last_command.should be_instance_of Connfu::Commands::Recording::Start
        end

        it "should record for maximum of 10 seconds" do
          expected_command = Connfu::Commands::Recording::Start.new(
            :call_jid => @call_jid,
            :client_jid => @client_jid,
            :max_length => 10 * 1000
          )
          last_command.should == expected_command
        end

        it "should assign the greeting to user account" do
          new_asset_location = "#{Rails.configuration.asset_handler_server}/assets/original-file"
          stub_request(:get, "#{Rails.configuration.asset_handler_server}/path/to/original-file").
                   to_return(:status => 200, :body => new_asset_location)

          incoming :recording_result_iq, @call_jid
          incoming :recording_stop_presence, @call_jid, 'file:/path/to/original-file'

          @account.reload.greeting_path.should == new_asset_location
        end
      end

      describe "recording the user's greeting when the Asset Handler service is unavailable" do
        before do
          incoming :result_iq, @call_jid
          incoming :say_success_presence, @call_jid
        end

        it "should handle exception raised when connection refused" do
          stub_request(:any, "#{Rails.configuration.asset_handler_server}/path/to/original-file").to_raise(Errno::ECONNREFUSED)

          incoming :recording_result_iq, @call_jid

          lambda { incoming :recording_stop_presence, @call_jid, 'file:/path/to/original-file' }.should_not raise_error
        end

        it "should not assign greeting_path to user account if 404 is returned" do
          stub_request(:get, "#{Rails.configuration.asset_handler_server}/path/to/original-file").
                   to_return(:status => 404, :body => "File not found")

          incoming :recording_result_iq, @call_jid
          lambda { incoming :recording_stop_presence, @call_jid, 'file:/path/to/original-file' }.should_not raise_error
        end
      end
    end
  end
end

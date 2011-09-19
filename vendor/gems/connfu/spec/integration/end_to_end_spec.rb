require "spec_helper"

$success = false

class DialAndAnswer
  include Connfu::Dsl

  on :offer do |call|
    answer
    say('hello')
    hangup
  end

  on :ready do
    dial :to => 'sip:usera@127.0.0.1', :from => "sip:userb@127.0.0.1" do |c|
      c.on_answer do
        $success = true
      end
    end
  end
end

describe "Dialing and answering a call" do
  
  it "should dial and answer the call" do
    pending 'we need to resolve leaking prism session issue'
    logfile = File.expand_path('../../../log/xmpp_test.log', __FILE__)
    Connfu.io_log = Connfu::Logging::IOLogger.new(logfile)
    
    Connfu.config.uri = ENV['PRISM_JID'] || 'jid://usera:1@127.0.0.1'
    thread = Thread.new { Connfu.start DialAndAnswer }

    finish_at = Time.now + 10
    while !$success && Time.now < finish_at do
      sleep 1
    end

    failure_message = "\nFailed!\nThis might be because Prism is playing up so the first step is to restart Prism and re-run this test.\nIf it continues to fail then an upgrade to Tropo has probably broken something."    
    $success.should be_true, failure_message
  end
  
end
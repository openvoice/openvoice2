require 'bundler/setup'
require 'rspec'
require 'connfu'
require 'cgi'

module ConnfuTestDsl
  def testing_dsl(&block)
    dsl_class = Class.new
    dsl_class.send(:include, Connfu::Dsl)
    dsl_class.class_eval(&block)
    before(:each) do
      @dsl_class = dsl_class
      setup_connfu(@dsl_class)
    end
    let(:dsl_instance) { dsl_class.any_instance }
  end
end

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.extend ConnfuTestDsl
end

l.level = Logger::WARN

class MyTestClass
  include Connfu
end

PRISM_HOST = '127.0.0.1'
PRISM_JID = "usera@#{PRISM_HOST}"
PRISM_PASSWORD = "1"

def setup_connfu(handler_class)
  Connfu.setup PRISM_JID, PRISM_PASSWORD
  Connfu.event_processor = Connfu::EventProcessor.new(handler_class)
  Connfu.adaptor = TestConnection.new
end

def incoming(type, *args)
  stanza = if type.to_s =~ /_iq$/
    create_iq(send(type, *args))
  else
    create_presence(send(type, *args))
  end
  Connfu.handle_stanza(stanza)
end

def create_presence(presence_xml)
  doc = Nokogiri::XML.parse presence_xml
  Blather::Stanza::Presence.import(doc.root)
end

def create_iq(iq_xml)
  doc = Nokogiri::XML.parse iq_xml
  Blather::Stanza::Iq.import(doc.root)
end

RSpec::Matchers.define :be_stanzas do |expected_stanzas|
  match do |actual|
    actual.map { |x| x.to_s.gsub(/\n\s*/, "\n") } == expected_stanzas.map { |x| x.to_s.gsub(/\n\s*/, "\n") }
  end
end

class TestConnection
  attr_accessor :commands

  def initialize
    @commands = []
  end

  def send_command(command)
    @commands << command
  end

  def jid
    Blather::JID.new('zlu', 'openvoice.org', '1')
  end
end

def result_iq(call_id='4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708')
  "<iq type='result' id='blather0008' from='#{call_id}@#{PRISM_HOST}' to='#{PRISM_JID}/voxeo'/>"
end

def error_iq(call_id='4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708')
  "<iq type='error' id='blather000c' from='#{call_id}@#{PRISM_HOST}' to='#{PRISM_JID}/voxeo'>
    <transfer xmlns='urn:xmpp:ozone:transfer:1'>
      <to>bollocks</to>
    </transfer>
    <error type='cancel'>
      <bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
      <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' lang='en'>Unsupported format: bollocks</text>
    </error>
  </iq>"
end

def offer_presence(from="4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@#{PRISM_HOST}", to="#{PRISM_JID}/voxeo", options={})
  offer_options = {
    :from => "<sip:16508983130@#{PRISM_HOST}>;tag=34ccaa4d",
    :to => "<sip:#{PRISM_JID}:5060>"
  }.merge(options)
  "<presence from='#{from}' to='#{to}'>
    <offer xmlns='urn:xmpp:ozone:1' to='sip:#{PRISM_JID}:5060' from='sip:16508983130@#{PRISM_HOST}'>
      <header name='Max-Forwards' value='70'/>
      <header name='Content-Length' value='422'/>
      <header name='Contact' value='&lt;sip:16508983130@#{PRISM_HOST}:21702&gt;'/>
      <header name='Supported' value='replaces'/>
      <header name='Allow' value='INVITE'/>
      <header name='To' value='#{CGI.escapeHTML(offer_options[:to])}'/>
      <header name='CSeq' value='1 INVITE'/>
      <header name='User-Agent' value='Bria 3 release 3.2 stamp 61503'/>
      <header name='Via' value='SIP/2.0/UDP #{PRISM_HOST}:21702;branch=z9hG4bK-d8754z-ab966854f39bb612-1---d8754z-;rport=21702'/>
      <header name='Call-ID' value='MGRkMWJiOTVmM2ViMGM4NWNiYmFhZDk5NGMwMDcwOTE.'/>
      <header name='Content-Type' value='application/sdp'/>
      <header name='From' value='#{CGI.escapeHTML(offer_options[:from])}'/>
    </offer>
  </presence>"
end

def answer_iq(call_id="9c011b43-b9be-4322-9adf-3d18e3af2f1b")
  %{<iq type="set" to="#{call_id}@#{PRISM_HOST}" id="blather000a" from="#{PRISM_JID}/voxeo">
    <answer xmlns="urn:xmpp:ozone:1"/>
  </iq>}
end

def say_complete_success(call_id='7bc6c7d5-1428-421d-bb40-22f58cdcd2ec')
  "<presence from='#{call_id}@#{PRISM_HOST}/a1b45d70-6df2-4460-b172-4bd077e8966d' to='#{PRISM_JID}/voxeo'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success xmlns='urn:xmpp:ozone:say:complete:1'/>
    </complete>
  </presence>"
end

def ask_complete_success(call_id="9f00061", catpured_input="1234")
  "<presence to='16577@app.ozone.net/1' from='#{call_id}@call.ozone.net/fgh4590'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success mode='speech' confidence='0.45' xmlns='urn:xmpp:ozone:ask:complete:1'>
        <interpretation>#{catpured_input}</interpretation>
        <utterance>one two three four</utterance>
      </success>
    </complete>
  </presence>"
end

def transfer_timeout_presence(call_id='9f00061')
  "<presence to='16577@app.ozone.net/1' from='#{call_id}@call.ozone.net/fgh4590'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <timeout xmlns='urn:xmpp:ozone:transfer:complete:1' />
    </complete>
  </presence>"
end

def transfer_success_presence(call_id='9f00061')
  "<presence to='16577@app.ozone.net/1' from='#{call_id}@call.ozone.net/fgh4590'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success xmlns='urn:xmpp:ozone:transfer:complete:1' />
    </complete>
  </presence>"
end

def transfer_busy_presence(call_id="c82737e4-f70c-466d-b839-924f69be57bd")
  %{<presence from="#{call_id}@#{PRISM_HOST}/7d858f27-e961-4aa2-ae9f-ecaffd4c841e" to="#{PRISM_JID}/voxeo">
    <complete xmlns="urn:xmpp:ozone:ext:1">
      <busy xmlns="urn:xmpp:ozone:transfer:complete:1"/>
    </complete>
  </presence>}
end

def transfer_rejected_presence(call_id="c82737e4-f70c-466d-b839-924f69be57bd")
  %{<presence from="#{call_id}@#{PRISM_HOST}/7d858f27-e961-4aa2-ae9f-ecaffd4c841e" to="#{PRISM_JID}/voxeo">
    <complete xmlns="urn:xmpp:ozone:ext:1">
      <reject xmlns="urn:xmpp:ozone:transfer:complete:1"/>
    </complete>
  </presence>}
end

def recording_result_iq(call_id="a0565638-90f8-416e-b26f-636f1aa684d0", id="f3c1b8c4-bb4f-4f7c-a063-87ee9bac0980")
  %{<iq type="result" id="blather000a" from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <ref xmlns="urn:xmpp:ozone:1" id="#{id}"/>
  </iq>}
end

def recording_stop_presence(call_id="abc123", id="def456", path="file:///tmp/recording.mp3")
  %{<presence from="#{call_id}@#{PRISM_HOST}/#{id}" to="#{PRISM_JID}/voxeo">
    <complete xmlns="urn:xmpp:ozone:ext:1">
      <stop xmlns="urn:xmpp:ozone:ext:complete:1"/>
      <recording uri="#{path}"/>
    </complete>
  </presence>}
end

def outgoing_call_ringing_presence(call_id="ebe45dbf-2a8b-4f1c-9aa0-1f1b39d1e821")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <ringing xmlns="urn:xmpp:ozone:1"/>
  </presence>}
end

def outgoing_call_answered_presence(call_id="ebe45dbf-2a8b-4f1c-9aa0-1f1b39d1e821")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <answered xmlns="urn:xmpp:ozone:1"/>
  </presence>}
end

def hangup_presence(call_id="abc")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <end xmlns="urn:xmpp:ozone:1">
      <hangup/>
    </end>
  </presence>}
end
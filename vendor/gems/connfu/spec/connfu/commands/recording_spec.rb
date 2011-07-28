require "spec_helper"

describe Connfu::Commands::Recording do

  describe "generating XMPP iq for a Start command" do
    subject do
      Connfu::Commands::Recording::Start.new(
        :to => 'server-address', :from => 'client-address'
      ).to_iq
    end

    it "should generate a record iq" do
      subject.xpath("//x:record", "x" => rayo('record:1')).should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should contain the 'to' address in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
    end

    it "should contain the 'from' address in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
    end

    it 'should have correct iq attributes for recording type' do
      node = subject.xpath("//x:record", "x" => rayo('record:1')).first
      node.attributes['start-beep'].value.should eq 'true'
    end
  end

  describe "generating XMPP iq for a Start command" do
    describe "with optional max length parameter" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :max_length => 25000
        ).to_iq
      end

      it 'should have max length set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['max-length'].value.should eq '25000'
      end
    end

    describe "with optional beep parameter" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :beep => false
        ).to_iq
      end

      it 'should have start-beep set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['start-beep'].value.should eq 'false'
      end
    end

    describe "with recording format passed as :wav" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :format => :wav
        ).to_iq
      end

      it 'should have format set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['format'].value.should eq 'WAV'
      end
    end

    describe "with recording format passed as :gsm" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :format => :gsm
        ).to_iq
      end

      it 'should have format set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['format'].value.should eq 'GSM'
      end
    end

    describe "with recording format passed as :raw" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :format => :raw
        ).to_iq
      end

      it 'should have format set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['format'].value.should eq 'RAW'
      end
    end

    describe "with recording format passed as :mp3" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :format => :mp3
        ).to_iq
      end

      it 'should have format set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['format'].value.should eq 'MP3'
      end
    end

    describe "with recording format passed as unsupported format" do
      it 'should raise exception' do
        lambda {
          Connfu::Commands::Recording::Start.new(
            :to => 'server-address', :from => 'client-address', :format => :unknown_format
          ).to_iq
        }.should raise_error(Connfu::Commands::Recording::InvalidEncoding, "Format unknown_format not supported")
      end
    end

    describe "with recording format and supported format codec" do
      subject do
        Connfu::Commands::Recording::Start.new(
          :to => 'server-address', :from => 'client-address', :format => :wav, :codec => :mulaw_pcm_64k
        ).to_iq
      end

      it 'should have format set correctly' do
        node = subject.xpath("//x:record", "x" => rayo('record:1')).first
        node.attributes['codec'].value.should eq 'MULAW_PCM_64K'
      end
    end

    describe "with recording format and unsupported format codec" do
      it 'should raise exception' do
        lambda {
          Connfu::Commands::Recording::Start.new(
            :to => 'server-address', :from => 'client-address', :format => :wav, :codec => :unknowncodec
          ).to_iq
        }.should raise_error(Connfu::Commands::Recording::InvalidEncoding, "Codec unknowncodec not supported for wav format")
      end
    end

    describe "passing format codec without specifying the format" do
      it 'should raise exception' do
        lambda {
          Connfu::Commands::Recording::Start.new(
            :to => 'server-address', :from => 'client-address', :codec => :mulaw_pcm_64k
          ).to_iq
        }.should raise_error(Connfu::Commands::Recording::InvalidEncoding, "Please supply :format when specifying :codec")
      end
    end

  end

  describe "generating XMPP iq for a Stop command" do
    subject do
      Connfu::Commands::Recording::Stop.new(:to => 'server-address', :from => 'client-address', :ref_id => 'abc123').to_iq
    end

    it "should generate a stop record iq" do
      subject.xpath("//x:stop", "x" => rayo('ext:1')).should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should contain the 'to' address with the ref_id in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "server-address/abc123"
    end

    it "should contain the 'from' address in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
    end

    it 'should not set any other iq attributes' do
      node = subject.xpath("//x:stop", "x" => rayo('ext:1')).first
      node.attributes.size.should eq 0
    end
  end
end
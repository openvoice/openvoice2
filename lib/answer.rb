require 'connfu'
require 'connfu/queue/resque'

uri = URI.parse(ENV['CONNFU_JABBER_URI'])
jid = "#{uri.user}@#{uri.host}"
Connfu.setup jid, uri.password
Resque.redis = "redis://redistogo:73d5d351c2595cc21b9d9baef231ccc6@catfish.redistogo.com:9458/"
# Resque.redis = "redis://localhost:6379"


Connfu.start do
  on :outgoing_call do |call|
    call.on_answer do
      p "Answered call"
      # check call number to see if I dialled it, or has already got voicemail message recorded....

      sleep 2 # avoid known prism/tropo bug
      say('please record your greeting')
      start_recording

      sleep 5

      p stop_recording

      hangup
    end

    call.on_ringing do
      p "Call is ringing"
    end
  end
end

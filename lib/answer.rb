require 'connfu'

Connfu.setup "usera@46.137.85.52", "1"
Connfu.redis_uri = "redis://redistogo:73d5d351c2595cc21b9d9baef231ccc6@catfish.redistogo.com:9458/"

class AnswerExample
  include Connfu::Dsl

  on :outgoing_call do |call|
    call.on_answer do
      p "Answered call"
      # check call number to see if I dialled it, or has already got voicemail message recorded....
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

Connfu.start AnswerExample

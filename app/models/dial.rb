#class Dial
#  include Connfu::Dsl
#
#  def on_answer
#    start_recording
#    sleep 5
#    file_name = stop_recording
#  end
#
#  def on_hangup
#    say 'good bye'
#  end
#end
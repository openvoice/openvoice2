require 'jobs'
require 'connfu'

class IncomingCall
  include Connfu::Dsl
  on :offer do |call|
    if account = Account.find_by_number(call.to[:username]) || Account.find_by_username(call.to[:username])
      call_record = account.calls.create!(:incoming => true, :party_address => call.from)
      answer
      say account.greeting_path || 'please wait while we transfer your call'

      play_hold_music

      if account.parallel_dial?
        call_ids = []
        account.endpoints.each do |endpoint|
          call_ids << dial_join({:dial_from => call.to[:address], :dial_to => endpoint.address})
        end

        answered_event = wait_for_one_leg_to_answer(call_ids)

        if answered_event.instance_of?(Connfu::Event::Answered)
          unanswered_calls = call_ids-[answered_event.call_id]
          hangup_calls(unanswered_calls)

          answered_call_id = answered_event.call_id
          hangup_openvoice_leg_when_caller_hangs_up(answered_call_id)
        end
      else
        answered_event = nil
        account.endpoints.detect do |endpoint|
          result = dial(:from => call.to[:address], :to => endpoint.address)
          answered_event = wait_for Connfu::Event::Answered, :timeout => 10

          answered_event.is_a?(Connfu::Event::Answered).tap do |answered|
            hangup "#{result.ref_id}@#{Connfu.connection.jid.domain}" unless answered
          end
        end

        if answered_event.is_a?(Connfu::Event::Answered)
          wait_because_of_tropo_bug_133

          result = send_command Connfu::Commands::Join.new(
            :call_jid => call_jid,
            :client_jid => client_jid,
            :call_id => answered_event.call_id
          )
          wait_for Connfu::Event::Joined
          logger.debug "Call established"

          answered_call_id = answered_event.call_id
          hangup_openvoice_leg_when_caller_hangs_up(answered_call_id)
        else
          logger.debug "The call wasn't answered."
          say "Sorry"
        end
      end

      logger.debug "The call has finished"
    end
  end

  private

  def play_hold_music
    # Not waiting after the command means the music will stop when one of the calls is answered
    send_command Connfu::Commands::Say.new(
      :call_jid => call_jid,
      :client_jid => client_jid,
      :text => "http://www.phono.com/audio/troporocks.mp3"
    )
  end

  def wait_for_one_leg_to_answer(call_ids)
    event = nil
    while (event = wait_for Connfu::Event::Answered, Connfu::Event::Rejected)
      if event.instance_of?(Connfu::Event::Rejected)
        call_ids.delete(event.call_id)
        break if call_ids.empty?
        next
      elsif event.instance_of?(Connfu::Event::Answered)
        break
      end
    end
    event
  end

  def hangup_calls(calls)
    calls.each do |hangup_call_id|
      hangup_call_jid = "#{hangup_call_id}@#{Connfu.connection.jid.domain}"
      hangup(hangup_call_jid)
    end
  end

  def hangup_openvoice_leg_when_caller_hangs_up(answered_call_id)
    result = wait_for Connfu::Event::Hangup
    if result.call_id == call_id # caller hangs up, hang up openvoice user
      logger.debug "The caller hung up; now hanging up the openvoice-established leg"
      answered_call_jid = "#{answered_call_id}@#{Connfu.connection.jid.domain}"
      hangup(answered_call_jid)
      finish!
    else
      logger.debug "Must've been the openvoice-established leg hanging up."
    end
  end
end

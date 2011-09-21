require 'jobs'
require 'connfu'

class IncomingCall
  include Connfu::Dsl

  attr_accessor :offer, :call_record

  on :offer do |offer|
    self.offer = offer

    if account
      self.call_record = account.calls.create!(:incoming => true, :party_address => offer.from)
      answer
      say account.greeting_path || 'please wait while we transfer your call'

      play_hold_music

      call_id, endpoint = *establish_call

      if call_id
        call_record.state = Connfu::Dsl::CallBehaviour::ANSWERED
        call_record.endpoint = endpoint
        call_record.save!

        hangup_openvoice_leg_when_caller_hangs_up(call_id)
      end

      logger.debug "The call has finished"
    end
  end

  private

  def account
    @account ||= Account.find_by_number(offer.to[:username]) || Account.find_by_username(offer.to[:username])
  end

  def establish_call
    if account.parallel_dial?
      establish_call_using_parallel_dial
    else
      establish_call_using_round_robin
    end
  end

  def establish_call_using_parallel_dial
    parallel_calls = account.endpoints.inject({}) do |memo, endpoint|
      call_id = dial_join({:dial_from => offer.to[:address], :dial_to => endpoint.address})
      memo[call_id] = endpoint
      memo
    end

    call_ids = parallel_calls.keys

    answered_event = wait_for_one_leg_to_answer(call_ids)

    if answered_event.instance_of?(Connfu::Event::Answered)
      unanswered_calls = call_ids - [answered_event.call_id]

      hangup_calls(unanswered_calls)

      answered_call_id = answered_event.call_id
      [answered_call_id, parallel_calls[answered_call_id]]
    end
  end

  def establish_call_using_round_robin
    event = nil
    endpoint = account.endpoints.detect do |endpoint|
      result = dial(:from => offer.to[:address], :to => endpoint.address)
      event = wait_for Connfu::Event::Answered, Connfu::Event::Rejected, :timeout => 10

      if event.is_a?(Connfu::Event::Answered) ||
         event.is_a?(Connfu::Event::Rejected)
        true
      else
        hangup "#{result.ref_id}@#{Connfu.connection.jid.domain}"
        false
      end
    end

    case event
    when Connfu::Event::Answered

      wait_because_of_tropo_bug_133

      result = send_command Connfu::Commands::Join.new(
        :call_jid => call_jid,
        :client_jid => client_jid,
        :call_id => event.call_id
      )

      wait_for Connfu::Event::Joined
      logger.debug "Call established"
      [event.call_id, endpoint]
    else
      stop_hold_music
      say "Please leave a message after the beep"
      record_for(60, :beep => true)
      say "Message complete"
      nil
    end
  end

  def play_hold_music
    # Not waiting after the command means the music will stop when one of the calls is answered
    result = send_command Connfu::Commands::Say.new(
      :call_jid => call_jid,
      :client_jid => client_jid,
      :text => "http://www.phono.com/audio/troporocks.mp3"
    )
    @hold_music_component_id = result.ref_id
  end

  def stop_hold_music
    send_command Connfu::Commands::Stop.new(
      :call_jid => call_jid,
      :client_jid => client_jid,
      :component_id => @hold_music_component_id
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

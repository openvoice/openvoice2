class Call < ActiveRecord::Base
  belongs_to :account
  belongs_to :endpoint

  STATES = [
    :rejected,
    :caller_ringing,
    :recipient_ringing,
    :caller_answered,
    :recipient_answered,
    :recipient_busy,
    :answered,
    :ended
  ]

  STATES.each do |state|
    const_set state.to_s.upcase, state
  end

  def openvoice_address
    endpoint.account.address
  end

  def update_state!(state)
    update_attributes(:state => state)
  end

  def state
    self['state'].to_sym
  end

  def display_state
    state.to_s.humanize
  end

end

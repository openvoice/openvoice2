class Call < ActiveRecord::Base
  belongs_to :endpoint

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

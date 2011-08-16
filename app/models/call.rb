class Call < ActiveRecord::Base
  belongs_to :endpoint

  def openvoice_number
    endpoint.account.number
  end

  def update_state!(state)
    update_attributes(:state => state)
  end

  def state
    self['state'].to_sym
  end

end

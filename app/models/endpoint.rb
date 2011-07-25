class Endpoint < ActiveRecord::Base
  belongs_to :account

  validates_presence_of :address, :account_id
end

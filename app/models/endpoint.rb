class Endpoint < ActiveRecord::Base
  belongs_to :account
  has_many :calls

  validates_presence_of :address, :account_id
end

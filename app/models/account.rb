class Account < ActiveRecord::Base
  has_secure_password
  has_many :endpoints

  validates_presence_of :email
end
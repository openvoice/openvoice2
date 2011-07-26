class Account < ActiveRecord::Base
  has_secure_password
  has_many :endpoints

  validates_presence_of :email, :username
  validates_uniqueness_of :email, :username

  def number
    "sip:#{username}@#{Connfu.config.host}"
  end
end
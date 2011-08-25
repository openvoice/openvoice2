class Account < ActiveRecord::Base

  def self.voxeo_provisioned_numbers
    [
      "4416196332775", "4416196332776", "4416196332777", "4416196332778", "4416196332779",
      "4416196332780", "4416196332781", "4416196332782", "4416196332783", "4416196332784",
      "442035149248",  "442035149249",  "442035149250",  "442035149251",  "442035149252",
      "442035149253",  "442035149254",  "442035149255",  "442035149256",  "442035149257"
    ]
  end

  has_secure_password
  has_many :endpoints
  has_many :calls

  validates_presence_of :email, :username
  validates_uniqueness_of :email, :username, :number
  validates_inclusion_of :number, :in => voxeo_provisioned_numbers, :allow_nil => true

  def address
    "sip:#{username}@#{Connfu.config.host}"
  end

end
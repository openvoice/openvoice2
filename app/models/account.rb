class Account < ActiveRecord::Base
  has_secure_password
  has_many :endpoints

  validates_presence_of :email, :username
  validates_uniqueness_of :email, :username, :number

  def address
    "sip:#{username}@#{Connfu.config.host}"
  end

  def provisioned_numbers
    {
      "+16196332775" => "zlu",
      "+16196332776" => "",
      "+16196332777" => "",
      "+16196332778" => "",
      "+16196332779" => "",
      "+16196332780" => "",
      "+16196332781" => "",
      "+16196332782" => "",
      "+16196332783" => "",
      "+16196332784" => "",
      "+442035149248" => "gfr",
      "+442035149249" => "",
      "+442035149250" => "",
      "+442035149251" => "",
      "+442035149252" => "",
      "+442035149253" => "",
      "+442035149254" => "",
      "+442035149255" => "",
      "+442035149256" => "",
      "+442035149257" => "",
    }
  end

end
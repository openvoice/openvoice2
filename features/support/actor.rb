module ActorSupport
  class Actor
    attr_accessor :email, :password

    def account=(account)
      @email, @password = account.email, account.password
    end

    def email
      @email ||= "me@example.com"
    end

    def username
      @username ||= "me"
    end

    def password
      @password ||= "letmein"
    end

    def number
      @number ||= "sip:me@127.0.0.1"
    end
  end

  def my
    @actor ||= Actor.new
  end
end

World(ActorSupport)
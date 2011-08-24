module ActorSupport
  class Actor
    attr_writer :email, :password

    def account
      Account.find_by_email(email)
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

    def address
      @address ||= "sip:me@127.0.0.1"
    end
  end

  def my
    @actor ||= Actor.new
  end
end

World(ActorSupport)
module ActorSupport
  class Actor
    attr_accessor :email, :password

    def account=(account)
      @email, @password = account.email, account.password
    end

    def email
      @email ||= "me@example.com"
    end

    def password
      @password ||= "letmein"
    end
  end

  def my
    @actor ||= Actor.new
  end
end

World(ActorSupport)
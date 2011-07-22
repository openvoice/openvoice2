module ActorSupport
  class Actor
    attr_accessor :account
  end

  def my
    @actor ||= Actor.new
  end
end

World(ActorSupport)
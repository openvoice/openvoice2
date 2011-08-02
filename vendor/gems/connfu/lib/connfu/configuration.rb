class Connfu::Configuration
  attr_accessor :uri, :user, :password, :host

  def initialize(options = {})
    self.uri = options[:uri] || ENV['CONNFU_JABBER_URI']
  end

  def uri=(u)
    @uri = u
    if u.nil?
      self.user = nil
      self.password = nil
      self.host = nil
    else
      URI.parse(u).tap do |parsed|
        self.user = parsed.user
        self.password = parsed.password
        self.host = parsed.host
      end
    end
  end
end
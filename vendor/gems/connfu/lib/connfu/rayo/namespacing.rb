module Connfu::Rayo::Namespacing
  def rayo(suffix = '')
    "urn:xmpp:rayo:#{suffix}"
  end

  def tropo(suffix = '')
    "urn:xmpp:tropo:#{suffix}"
  end
end

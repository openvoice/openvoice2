require 'connfu/queue/resque'
Resque.redis = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
Connfu.config.uri = ENV['CONNFU_JABBER_URI'] || "jid://usera:1@127.0.0.1"
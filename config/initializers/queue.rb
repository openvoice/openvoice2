require 'connfu/queue/resque'
Connfu::Queue::Resque.redis = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
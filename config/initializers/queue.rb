require 'connfu/queue/resque'
Resque.redis = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
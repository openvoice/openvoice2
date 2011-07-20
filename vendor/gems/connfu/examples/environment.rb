require 'rubygems'
require 'bundler/setup'
require 'connfu'

CONNFU_CONFIG = {
  'default' => {
    :jid       => 'usera@127.0.0.1',
    :password  => '1',
    :redis_url => 'redis://localhost:6379'
  }
}
CONNFU_CONFIG['amazon'] = CONNFU_CONFIG['default'].merge(:jid => 'usera@46.137.85.52')

CONNFU_ENV = ENV['CONNFU_ENV'] || 'default'

Connfu.setup CONNFU_CONFIG[CONNFU_ENV][:jid], CONNFU_CONFIG[CONNFU_ENV][:password]

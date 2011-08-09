#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    reject
  end
end
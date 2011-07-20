#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class RedirectExample
  include Connfu::Dsl

  on :offer do |call|
    redirect('sip:16508983130@127.0.0.1')
  end
end

Connfu.start RedirectExample
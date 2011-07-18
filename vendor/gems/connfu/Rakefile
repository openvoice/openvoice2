require 'bundler'
Bundler::GemHelper.install_tasks

require 'bundler/setup'

task :default => [:test]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test) do |spec|
  spec.skip_bundler = true
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = '--color'
end

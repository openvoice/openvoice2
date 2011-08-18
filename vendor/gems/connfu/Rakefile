require 'bundler'
Bundler::GemHelper.install_tasks

require 'bundler/setup'

types = [:connfu, :functional, :integration]
task :default => types

require 'rspec/core/rake_task'
types.each do |type|
  RSpec::Core::RakeTask.new(type) do |spec|
    spec.skip_bundler = true
    spec.pattern = "spec/#{type}/**/*_spec.rb"
    spec.pattern = [spec.pattern, 'spec/connfu_spec.rb'] if type == :connfu
    spec.rspec_opts = '--color'
  end
end

possible_prism_locations = ['~/Applications/prism', '/Applications/prism', '/opt/voxeo/prism'].map { |p| File.expand_path(p) }
prism_home = possible_prism_locations.find { |p| File.directory?(p) }
tropo_build_path = "#{prism_home}/apps/tropo-build.txt"

namespace :tropo do
  desc "Updates tropo to the latest version and restarts prism"
  task :update => "prism:exists" do
    require 'tmpdir'

    download_dir = File.join(Dir.tmpdir, 'tropo2')

    system "mkdir -p #{download_dir}"

    puts "* Downloading latest successful build of Tropo2"
    system "cd #{download_dir} && wget -q http://hudson.voxeolabs.com/hudson/job/Tropo%202/lastSuccessfulBuild/artifact/*zip*/archive.zip"
    puts "* Downloaded to #{File.join(download_dir, 'archive.zip')}"

    puts "* Unzipping tropo2"
    system "cd #{download_dir} && unzip archive.zip"

    puts "* Updating tropo2"
    tropo_war = Dir["#{download_dir}/archive/tropo-war/target/tropo-*.war"][0]
    build_number = File.basename(tropo_war, ".war").split("_").last
    File.open(tropo_build_path, "w") { |f| f.write build_number }
    system "cd #{download_dir} && rm -rf #{prism_home}/apps/tropo2 && mv archive/tropo-war/target/tropo-*.war #{prism_home}/apps/tropo2.war"

    puts "* Cleaning up"
    system "cd #{download_dir} && rm archive.zip"
    system "cd #{download_dir} && rm -rf archive"

    puts "* Restarting Prism server ..."
    Rake::Task["prism:restart"].invoke
    puts "* Prism server restarted."
    Rake::Task["tropo:version"].invoke
  end

  desc "Reports the version of Tropo running on local Prism server"
  task :version => "prism:exists" do
    require "open-uri"
    require "json"

    puts
    begin
      io = open("http://localhost:8080/tropo2/jmx/read/com.tropo:Type=Info")
      attributes = JSON.parse(io.read)
      puts "Tropo build info via JMX :-"
      attributes['value'].each { |pair| puts "* %s: %s" % pair }
    rescue
      puts "No Tropo build info available via JMX."
    end

    puts
    begin
      File.open(tropo_build_path) do |f|
        tropo_build_number = f.read.sub(%r{^b}, '')
        puts "Last downloaded Tropo build: %s" % tropo_build_number
      end
    rescue
      puts "No downloaded Tropo builds found."
    end
  end
end

namespace :prism do
  desc "Check that we know where prism is installed"
  task :exists do
    raise "Couldn't find prism" unless prism_home
  end

  desc "Start the Prism application & media servers"
  task :start => :exists do
    system "#{prism_home}/bin/prism start"
    abort("Error starting Prism") unless $?.success?
  end

  desc "Stop the Prism application & media servers"
  task :stop => :exists do
    system("#{prism_home}/bin/prism stop")
    abort("Error stopping Prism") unless $?.success?
  end

  desc "Restart the Prism application & media servers"
  task :restart => :exists do
    system("#{prism_home}/bin/prism restart")
    abort("Error restarting Prism") unless $?.success?
  end
end
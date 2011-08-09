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

possible_prism_locations = ['~/Applications/prism', '/Applications/prism', '/opt/voxeo/prism'].map { |p| File.expand_path(p) }
prism_home = possible_prism_locations.find { |p| File.directory?(p) }

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
    File.open("#{prism_home}/apps/tropo-build.txt", "w") { |f| f.write build_number }
    system "cd #{download_dir} && mv archive/tropo-war/target/tropo-*.war #{prism_home}/apps/tropo2.war"

    puts "* Cleaning up"
    system "cd #{download_dir} && rm archive.zip"
    system "cd #{download_dir} && rm -rf archive"

    puts "* Restarting Prism server ..."
    Rake::Task["prism:restart"].invoke
    puts "* Prism server restarted."
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
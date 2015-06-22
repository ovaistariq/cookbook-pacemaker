require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'
require 'kitchen'
require 'mixlib/shellout'
require 'kitchen/rake_tasks'

# Style tests. Rubocop and Foodcritic
namespace :style do
  desc "Run RuboCop style and lint checks"
  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ["-D"]
  end

  desc "Run Foodcritic lint checks"
  FoodCritic::Rake::LintTask.new(:foodcritic) do |t|
    t.options = { :fail_tags => ["any"] }
  end
end

desc "Run all style tests"
task :style => ['style:rubocop', 'sytle:foodcritic']

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run test-kitchen pre-processing scripts'
  task :pre_cmds do
    cmd = Mixlib::ShellOut.new('./scripts/write_vagrantfile.rb')
    cmd.run_command
  end

  desc 'Setup the test-kitchen vagrant instances'
  task :vagrant_setup do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      # serial execution cuz virtualbox/vagrant can't parallelize this part
      instance.destroy()

      # this happens serially because virualbox/vagrant can't handle
      # parallel vm creation
      instance.create()

      # Initial converge
      instance.converge()

      # Then the second converge to enable the pacemaker resource agents
      instance.converge()
    end
  end

  desc 'Verify the test-kitchen vagrant instances'
  task :vagrant_verify do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      # Run the integration tests now
      instance.verify()
    end
  end
end

# Clean up
namespace :cleanup do
  desc 'Destroy test-kitchen instances'
  task :kitchen_destroy do
    destroy = Kitchen::RakeTasks.new do |obj|
      def obj.destroy
        config.instances.each(&:destroy)
      end
    end
    destroy.destroy
  end

  desc 'Remove vagrant disks'
  task :rm_vdi do
    ::FileUtils.rm_rf('./vagrant_disks')
  end

  desc 'Remove Vagrantfiles/ dir'
  task :rm_vagrantfiles do
    ::FileUtils.rm_rf('./Vagrantfiles')
  end

  desc 'Remove .kitchen.local.yml'
  task :rm_kitchen_local do
    ::File.unlink('.kitchen.local.yml') if ::File.exist?('.kitchen.local.yml')
  end
end

desc 'Generate the setup'
task setup: ['integration:pre_cmds']

desc 'Clean up generated files'
task cleanup: ['cleanup:kitchen_destroy', 'cleanup:rm_vdi',
                 'cleanup:rm_kitchen_local', 'cleanup:rm_vagrantfiles']

desc 'Run full integration'
task integration: ['integration:pre_cmds', 'integration:vagrant_setup', 'integration:vagrant_verify']

# Default
task default: ['style', 'spec', 'integration:vagrant_setup', 'integration']

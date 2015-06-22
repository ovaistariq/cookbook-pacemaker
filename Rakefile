require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'
require 'kitchen'

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
  desc 'Run Test Kitchen with Vagrant'

  task :vagrant do
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

      # Run the integration tests now
      instance.verify()
    end
  end
end

# Default
task default: ['style', 'spec', 'integration:vagrant']

require "bundler"
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

task :default => :spec

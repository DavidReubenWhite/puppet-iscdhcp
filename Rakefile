require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?

PuppetLint.configuration.send('disable_relative')

desc "Run tests but don't clean up spec dir"
task :spec_noclean do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end

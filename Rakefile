require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/test_app/spec/*_spec.rb'
end

task default: :spec

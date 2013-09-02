task :default => "spec:run"

require "rspec/core/rake_task"

namespace :spec do
  desc "Run the tests."
  RSpec::Core::RakeTask.new(:run) do |spec|
    spec.pattern = "spec/**/*_spec.rb"
  end
end


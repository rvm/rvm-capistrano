#!/usr/bin/ruby

guard_opts = {
  all_on_start:   true,
  all_after_pass: true,
}

def all
  'spec'
end

group :bundler do
  guard 'bundler' do
    watch('Gemfile')
  end
end

group :tests do
  guard 'rspec', guard_opts do
    watch(%r{^spec/spec_helper\.rb})          { all }
    watch(%r{^spec/support/.+\.rb})           { all }
    watch(%r{^spec/.+_spec\.rb})
    watch(%r{^lib/(.+)\.rb})                  { all }
    watch(%r{^Gemfile$})                      { all }
    watch(%r{^Gemfile.lock$})                 { all }
  end
end

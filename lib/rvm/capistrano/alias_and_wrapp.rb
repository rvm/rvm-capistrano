require 'rvm/capistrano/base'
require 'rvm/capistrano/helpers/with_rvm_group'

rvm_with_capistrano do
  namespace :rvm do

    desc "Create application alias"
    rvm_task :create_alias do
      run_rvm("alias create #{application} #{rvm_ruby_string_evaluated}", :with_rvm_group => true)
    end

    desc "Show application alias path to wrappers"
    rvm_task :show_alias_path do
      run("ls #{rvm_path}/wrappers/#{application}/*")
    end

    desc "Create application wrappers"
    rvm_task :create_wrappers  do
      run_rvm("wrapper #{rvm_ruby_string_evaluated} --no-prefix --all",
               :with_rvm_group => true,
               :subject_class => :wrappers)
    end

  end
end

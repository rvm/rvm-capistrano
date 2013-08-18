require 'rvm/capistrano/base'

rvm_with_capistrano do
  namespace :rvm do

    desc "Install a gem, 'cap rvm:install_gem GEM=my_gem'."
    rvm_task :install_gem do
      run_rvm("gem install #{ENV['GEM']}",
               :with_ruby => rvm_ruby_string_evaluated,
               :subject_class => :gemsets)
    end

    desc "Uninstall a gem, 'cap rvm:uninstall_gem GEM=my_gem'."
    rvm_task :uninstall_gem do
      run_rvm("gem uninstall --no-executables #{ENV['GEM']}",
               :with_ruby => rvm_ruby_string_evaluated,
               :subject_class => :gemsets)
    end

  end
end

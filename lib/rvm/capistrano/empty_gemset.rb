# Extension to empty gemset.

module Capistrano extend self
  Configuration.instance(true).load do
    namespace :rvm do
      desc "Empty gemset"
      task :empty_gemset do
        ruby, gemset = rvm_ruby_string.to_s.strip.split /@/
        if %w( release_path default ).include? "#{ruby}"
          raise "gemset can not be emptied when using :rvm_ruby_string => :#{ruby}"
        else
          if gemset
            run "#{File.join(rvm_bin_path, "rvm")} #{ruby} do rvm --force gemset empty #{gemset}", :shell => "#{rvm_install_shell}"
          end
        end
      end
    end
  end if const_defined? :Configuration
end

# Extension to empty gemset.

require 'rvm/capistrano/base'

rvm_with_capistrano do
  namespace :rvm do

    desc "Empty gemset"
    task :empty_gemset do
      ruby, gemset = rvm_ruby_string_evaluated.to_s.strip.split /@/
      if %w( release_path default ).include? "#{ruby}"
        raise "gemset can not be emptied when using :rvm_ruby_string => :#{ruby}"
      else
        if gemset
          run_rvm("rvm --force gemset empty #{gemset}",
                   :with_rvm_group => true, :with_ruby => ruby,
                   :subject_class => :gemsets)
        end
      end
    end

  end
end

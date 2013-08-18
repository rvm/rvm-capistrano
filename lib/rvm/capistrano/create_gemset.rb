require 'rvm/capistrano/base'
require 'rvm/capistrano/helpers/with_rvm_group'

rvm_with_capistrano do
  namespace :rvm do

    desc "Create gemset"
    rvm_task :create_gemset do
      ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split(/@/)
      if %w( release_path default ).include? "#{ruby}"
        raise "

gemset can not be created when using :rvm_ruby_string => :#{ruby}

"
      else
        if gemset
          run_rvm("rvm gemset create #{gemset}",
                  :with_rvm_group => true, :with_ruby => ruby,
                  :subject_class => :gemsets)
        end
      end
    end

  end
end

require 'rvm/capistrano/base'

rvm_with_capistrano do

  namespace :rvm do

    desc <<-EOF
      Import file contents to the current RVM ruby gemset.

      The gemset filename must match :rvm_ruby_string.gems and be located in :rvm_gemset_path.
      :rvm_gemset_path defaults to :rvm_path/gemsets

      The gemset can be created with 'cap rvm:gemset_export'.
    EOF
    rvm_task :import_gemset do
      ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split(/@/)
      if %w( release_path default ).include? "#{ruby}"
        raise "gemset can not be imported when using :rvm_ruby_string => :#{ruby}"
      else
        if gemset
          ruby = fetch(:rvm_ruby_string_evaluated)
          run_rvm("rvm gemset import #{File.join(rvm_gemset_path, "#{ruby}.gems")}", :with_ruby => ruby)
        end
      end
    end

    desc <<-EOF
      Export the current RVM ruby gemset contents to a file.

      The gemset filename will match :rvm_ruby_string.gems and be located in :rvm_gemset_path.
      :rvm_gemset_path defaults to :rvm_path/gemsets

      The gemset can be imported with 'cap rvm:gemset_import'.
    EOF
    rvm_task :export_gemset do
      ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split(/@/)
      if %w( release_path default ).include? "#{ruby}"
        raise "gemset can not be exported when using :rvm_ruby_string => :#{ruby}"
      else
        if gemset
          ruby = fetch(:rvm_ruby_string_evaluated)
          run_rvm("rvm gemset export > #{File.join(rvm_gemset_path, "#{ruby}.gems")}", :with_ruby => ruby)
        end
      end
    end

  end

end

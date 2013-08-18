require 'rvm/capistrano/base'
require 'rvm/capistrano/helpers/run_silent_curl'
require 'rvm/capistrano/helpers/rvm_if_sudo'
require 'rvm/capistrano/helpers/with_rvm_group'

rvm_with_capistrano do

  deferred_load do

    # Let users set the (re)install for ruby.
    _cset(:rvm_install_ruby, :install)

    # Pass no special params to the ruby build by default
    _cset(:rvm_install_ruby_params, '')

  end

  namespace :rvm do

    desc <<-EOF
      Install RVM ruby to the server, create gemset if needed.
      By default ruby is installed, you can reinstall with:

      set :rvm_install_ruby, :reinstall

      By default ruby is compiled using all CPU cores, change with:

      set :rvm_install_ruby_threads, 5

      By default BASH is used for installer, change with:

      set :rvm_install_shell, :zsh
    EOF
    rvm_task :install_ruby do
      ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split(/@/)
      if %w( release_path default ).include? "#{ruby}"
        raise "

ruby can not be installed when using :rvm_ruby_string => :#{ruby}

"
      else
        command_install = rvm_user_command(:subject_class => :rubies, :with_ruby=>ruby)

        autolibs_flag = fetch(:rvm_autolibs_flag, 2).to_s
        autolibs_flag_no_requirements = %w(
          0 disable disabled
          1 read    read-only
          2 fail    read-fail
        ).include?( autolibs_flag )
        autolibs_flag = "1" unless autolibs_flag_no_requirements

        install_ruby_threads = fetch(:rvm_install_ruby_threads,nil).nil? ? '' : "-j #{rvm_install_ruby_threads}"
        unless autolibs_flag_no_requirements
          command_install << "#{rvm_if_sudo} #{path_to_bin_rvm} --autolibs=#{autolibs_flag} requirements #{ruby}"
          command_install << "; "
        end
        command_install << with_rvm_group("#{path_to_bin_rvm} --autolibs=#{autolibs_flag} #{rvm_install_ruby} #{ruby} #{install_ruby_threads} #{rvm_install_ruby_params}", :subject_class => :rubies)

        if gemset
          command_install << "; "
          command_install << with_rvm_group("#{path_to_bin_rvm(:with_ruby=>ruby)} rvm gemset create #{gemset}", :subject_class => :gemsets)
        end

        run_silent_curl(command_install, :subject_class => :rubies)
      end
    end

  end

end

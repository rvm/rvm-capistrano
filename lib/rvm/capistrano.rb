# Recipes for using RVM on a server with capistrano.

require 'rvm/capistrano/selector'

module Capistrano
  Configuration.instance(true).load do

    unless methods.map(&:to_sym).include?(:_cset)
      # Taken from the capistrano code.
      def _cset(name, *args, &block)
        unless exists?(name)
          set(name, *args, &block)
        end
      end
    end

    class << self
      def quote_and_escape(text, quote = "'")
        "#{quote}#{text.gsub(/#{quote}/) { |m| "#{quote}\\#{quote}#{quote}" }}#{quote}"
      end
    end

    # this is part of check, search for :rvm_require_role
    unless fetch(:rvm_require_role,nil).nil?
      set :rvm_require_role_was_set_before_require, true
      class << self
        def run(cmd, options={}, &block)
          if options[:eof].nil? && !cmd.include?(sudo)
            options = options.merge(:eof => !block_given?)
          end
          shell = options[:shell]
          options[:shell] = false

          parallel(options) do |session|
            if shell.nil?
              session.when "in?(:#{fetch(:rvm_require_role,nil)})", command_with_shell(cmd, fetch(:rvm_shell)), &block
            end
            session.else command_with_shell(cmd, shell), &block
          end
        end
        def command_with_shell(cmd, shell=nil)
          if shell == false
            cmd
          else
            "#{shell || "sh"} -c #{quote_and_escape(cmd)}"
          end
        end
      end
    end

    on :load do

      # this is part of check, search for :rvm_require_role
      if ! fetch(:rvm_require_role,nil).nil? and fetch(:rvm_require_role_was_set_before_require, nil).nil?
        raise "

ERROR: detected 'set :rvm_require_role, \"#{fetch(:rvm_require_role,nil)}\"' after 'require \"rvm/capistrano\"', please move it above for proper functioning.

"
      end

      # Let users configure a path to export/import gemsets
      _cset(:rvm_gemset_path, "#{rvm_path}/gemsets")

      # Default sudo state
      _cset(:rvm_install_with_sudo, false)

      # Let users set the install type and shell of their choice.
      _cset(:rvm_install_type, :stable)
      _cset(:rvm_install_shell, :bash)

      # Let users set the (re)install for ruby.
      _cset(:rvm_install_ruby, :install)

      # Pass no special params to the ruby build by default
      _cset(:rvm_install_ruby_params, '')

      # Additional rvm packages to install.
      _cset(:rvm_install_pkgs, [])

      # By default system installations add deploying user to rvm group. also try :all
      _cset(:rvm_add_to_group, fetch(:user,"$USER"))

    end

    namespace :rvm do

      def run_silent_curl(command)
        run(<<-EOF.gsub(/[\s]+/, ' '), :shell => "#{rvm_install_shell}")
          __LAST_STATUS=0;
          export CURL_HOME="${TMPDIR:-${HOME}}/.rvm-curl-config.$$";
          mkdir ${CURL_HOME}/;
          {
            [[ -r ${HOME}/.curlrc ]] && cat ${HOME}/.curlrc;
            echo "silent";
            echo "show-error";
          } > $CURL_HOME/.curlrc;
          #{command} || __LAST_STATUS=$?;
          rm -rf $CURL_HOME;
          exit ${__LAST_STATUS}
        EOF
      end

      def rvm_if_sudo(options = {})
        case rvm_type
        when :root, :system
          if fetch(:use_sudo, true) == false && rvm_install_with_sudo == false
            explanation = <<-EXPLANATION
You can enable use_sudo within rvm for use only by this install operation by adding to deploy.rb:

    set :rvm_install_with_sudo, true

            EXPLANATION
            if options[:deferred]
              <<-DEFERRED_ERROR.gsub(/\n/, " ; ")
echo "
Neither :use_sudo or :rvm_install_with_sudo was set and installation would ended up in using 'sudo'
#{explanation}
" >&2
exit 1
              DEFERRED_ERROR
            else
              raise "

:use_sudo is set to 'false' but sudo is needed to install rvm_type: #{rvm_type}.
#{explanation}
"
            end
          else
            "#{sudo} "
          end
        else
          ''
        end
      end

      def with_rvm_group(command)
        case rvm_type
        when :root, :system
          <<-CODE
if id | grep ' groups=.*(rvm)' >/dev/null ;
then #{command} ;
else #{rvm_if_sudo(:deferred=>true)} sg rvm -c #{quote_and_escape(command)} ;
fi
          CODE
        else
          command
        end
      end

      def rvm_task(name,&block)
        if fetch(:rvm_require_role,nil).nil?
          task name, &block
        else
          task name, :roles => fetch(:rvm_require_role), &block
        end
      end

      desc <<-EOF
        Install RVM of the given choice to the server.
        By default RVM "stable" is installed, change with:

        set :rvm_install_type, :head

        By default BASH is used for installer, change with:

        set :rvm_install_shell, :zsh
      EOF
      rvm_task :install_rvm do
        command_fetch    = "curl -L get.rvm.io"
        command_install  = rvm_if_sudo
        command_install << "#{rvm_install_shell} -s #{rvm_install_type} --path #{rvm_path}"
        case rvm_type
        when :root, :system
          command_install << " --add-to-rvm-group #{[rvm_add_to_group].flatten.map(&:to_s).join(",")}"
        end
        run_silent_curl "#{command_fetch} | #{command_install}"
      end

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
          command_install = ""

          autolibs_flag = fetch(:rvm_autolibs_flag, 2).to_s
          autolibs_flag_no_requirements = %w(
            0 disable disabled
            1 read    read-only
            2 fail    read-fail
          ).include?( autolibs_flag )

          install_ruby_threads = fetch(:rvm_install_ruby_threads,nil).nil? ? '' : "-j #{rvm_install_ruby_threads}"

          if autolibs_flag_no_requirements
            command_install << with_rvm_group("#{File.join(rvm_bin_path, "rvm")} --autolibs=#{autolibs_flag} #{rvm_install_ruby} #{ruby} #{install_ruby_threads} #{rvm_install_ruby_params}")
          else
            command_install << "#{rvm_if_sudo} #{File.join(rvm_bin_path, "rvm")} --autolibs=#{autolibs_flag} requirements #{ruby}"
            command_install << "; "
            command_install << with_rvm_group("#{File.join(rvm_bin_path, "rvm")} --autolibs=1 #{rvm_install_ruby} #{ruby} #{install_ruby_threads} #{rvm_install_ruby_params}")
          end

          if gemset
            command_install << "; "
            command_install << with_rvm_group("#{File.join(rvm_bin_path, "rvm")} #{ruby} do rvm gemset create #{gemset}")
          end

          run_silent_curl command_install
        end
      end

      desc <<-EOF
        Install RVM packages to the server.

        This must come before the 'rvm:install_ruby' task is called.

        The package list is empty by default.  Specifiy the packages to install with:

        set :rvm_install_pkgs, %w[libyaml curl]

        Full list of packages available at https://rvm.io/packages/ or by running 'rvm pkg'.
      EOF
      rvm_task :install_pkgs do
        rvm_install_pkgs.each do |pkg|
          run "#{File.join(rvm_bin_path, "rvm")} pkg install #{pkg}", :shell => "#{rvm_install_shell}"
        end
      end

      desc "Create gemset"
      rvm_task :create_gemset do
        ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split(/@/)
        if %w( release_path default ).include? "#{ruby}"
          raise "

gemset can not be created when using :rvm_ruby_string => :#{ruby}

"
        else
          if gemset
            run with_rvm_group("#{File.join(rvm_bin_path, "rvm")} #{ruby} do rvm gemset create #{gemset}"), :shell => "#{rvm_install_shell}"
          end
        end
      end

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
            run "#{File.join(rvm_bin_path, "rvm-shell")} #{fetch(:rvm_ruby_string_evaluated)} rvm gemset import #{File.join(rvm_gemset_path, "#{fetch(:rvm_ruby_string_evaluated)}.gems")}", :shell => "#{rvm_install_shell}"
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
          raise "gemset can not be imported when using :rvm_ruby_string => :#{ruby}"
        else
          if gemset
            run "#{File.join(rvm_bin_path, "rvm-shell")} #{fetch(:rvm_ruby_string_evaluated)} rvm gemset export > #{File.join(rvm_gemset_path, "#{fetch(:rvm_ruby_string_evaluated)}.gems")}", :shell => "#{rvm_install_shell}"
          end
        end
      end

      desc "Install a gem, 'cap rvm:install_gem GEM=my_gem'."
      rvm_task :install_gem do
        run "#{File.join(rvm_bin_path, "rvm")} #{fetch(:rvm_ruby_string_evaluated)} do gem install #{ENV['GEM']}", :shell => "#{rvm_install_shell}"
      end

      desc "Uninstall a gem, 'cap rvm:uninstall_gem GEM=my_gem'."
      rvm_task :uninstall_gem do
        run "#{File.join(rvm_bin_path, "rvm")} #{fetch(:rvm_ruby_string_evaluated)} do gem uninstall --no-executables #{ENV['GEM']}", :shell => "#{rvm_install_shell}"
      end

    end
  end if Capistrano.const_defined? :Configuration and Capistrano::Configuration.methods.map(&:to_sym).include? :instance
end

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

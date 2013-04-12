# Recipes for using RVM on a server with capistrano.

module Capistrano
  Configuration.instance(true).load do

    # Taken from the capistrano code.
    def _cset(name, *args, &block)
      unless exists?(name)
        set(name, *args, &block)
      end
    end

    _cset :rvm_shell do
      shell = File.join(rvm_bin_path, "rvm-shell")
      ruby = fetch(:rvm_ruby_string_evaluated).strip
      case ruby
      when "release_path"
        shell = "rvm_path=#{rvm_path} #{shell} --path '#{release_path}'"
      when "local"
        ruby = (ENV['GEM_HOME'] || "").gsub(/.*\//, "")
        raise "Failed to get ruby version from GEM_HOME. Please make sure rvm is loaded!" if ruby.empty?
        shell = "rvm_path=#{rvm_path} #{shell} '#{ruby}'"
      else
        shell = "rvm_path=#{rvm_path} #{shell} '#{ruby}'" unless ruby.empty?
      end
      shell
    end
    if fetch(:rvm_require_role,nil).nil?
      _cset :default_shell do
        fetch(:rvm_shell)
      end
    else
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
            "#{shell || "sh"} -c '#{cmd.gsub(/'/) { |m| "'\\''" }}'"
          end
        end
      end
    end

    # Let users set the type of their rvm install.
    _cset(:rvm_type, :user)

    # Define rvm_path
    # This is used in the default_shell command to pass the required variable to rvm-shell, allowing
    # rvm to boostrap using the proper path.  This is being lost in Capistrano due to the lack of a
    # full environment.
    _cset(:rvm_path) do
      case rvm_type
      when :root, :system
        "/usr/local/rvm"
      when :local, :user, :default
        "$HOME/.rvm/"
      else
        rvm_type.to_s.empty? ?  "$HOME/.rvm" : rvm_type.to_s
      end
    end

    # Let users override the rvm_bin_path
    _cset(:rvm_bin_path) do
      case rvm_type
      when :root, :system
        "/usr/local/rvm/bin"
      when :local, :user, :default
        "$HOME/.rvm/bin"
      else
        rvm_type.to_s.empty? ?  "#{rvm_path}/bin" : rvm_type.to_s
      end
    end

    set :rvm_ruby_string_evaluated do
      value = fetch(:rvm_ruby_string, :default)
      if value.to_sym == :local
        value = ENV['GEM_HOME'].gsub(/.*\//,"")
      end
      value.to_s
    end

    # Let users configure a path to export/import gemsets
    _cset(:rvm_gemset_path, "#{rvm_path}/gemsets")

    # Use the default ruby on the server, by default :)
    _cset(:rvm_ruby_string, :default)

    # Default sudo state
    _cset(:rvm_install_with_sudo, false)

    # Let users set the install type and shell of their choice.
    _cset(:rvm_install_type, :stable)
    _cset(:rvm_install_shell, :bash)

    # Let users set the (re)install for ruby.
    _cset(:rvm_install_ruby, :install)
    _cset(:rvm_install_ruby_threads, "$(cat /proc/cpuinfo 2>/dev/null | (grep vendor_id || echo 'vendor_id : Other';) | wc -l)")

    # Pass no special params to the ruby build by default
    _cset(:rvm_install_ruby_params, '')

    # Additional rvm packages to install.
    _cset(:rvm_install_pkgs, [])

    # By default system installations add deploying user to rvm group. also try :all
    _cset(:rvm_add_to_group, fetch(:user,"$USER"))

    namespace :rvm do

      def run_silent_curl(command)
        run <<-EOF.gsub(/[\s\n]+/, ' '), :shell => "#{rvm_install_shell}"
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

      def with_rvm_group(command)
        case rvm_type
        when :root, :system
          "sg rvm -c \"#{command}\""
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
        command_install  = case rvm_type
          when :root, :system
            if fetch(:use_sudo, true) == false && rvm_install_with_sudo == false
              raise "

:use_sudo is set to 'false' but sudo is needed to install rvm_type: #{rvm_type}.
You can enable use_sudo within rvm for use only by this install operation by adding to deploy.rb: set :rvm_install_with_sudo, true

"
            else
              "#{sudo} "
            end
          else
            ''
          end
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

        set :rvm_install_ruby_threads, :reinstall

        By default BASH is used for installer, change with:

        set :rvm_install_shell, :zsh
      EOF
      rvm_task :install_ruby do
        ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split /@/
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

          if autolibs_flag_no_requirements
            command_install << with_rvm_group("#{File.join(rvm_bin_path, "rvm")} --autolibs=#{autolibs_flag} #{rvm_install_ruby} #{ruby} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}")
          else
            if fetch(:use_sudo, true) == false && rvm_install_with_sudo == false
              raise "

:use_sudo is set to 'false' but sudo is needed to install requirements with autolibs '#{autolibs_flag}'.
You can enable use_sudo within rvm for use only by this ruby install operation by adding to deploy.rb: set :rvm_install_with_sudo, true

"
            else
              command_install << "#{sudo} #{File.join(rvm_bin_path, "rvm")} --autolibs=#{autolibs_flag} requirements #{ruby}"
              command_install << "; "
              command_install << with_rvm_group("#{File.join(rvm_bin_path, "rvm")} --autolibs=1 #{rvm_install_ruby} #{ruby} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}")
            end
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
        ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split /@/
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
        ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split /@/
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
        ruby, gemset = fetch(:rvm_ruby_string_evaluated).to_s.strip.split /@/
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

# E.g, to use ree and rails 3:
#
#   require 'rvm/capistrano'
#   set :rvm_ruby_string, "ree@rails3"
#

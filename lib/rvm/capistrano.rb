# Recipes for using RVM on a server with capistrano.

module Capistrano
  Configuration.instance(true).load do

    # Taken from the capistrano code.
    def _cset(name, *args, &block)
      unless exists?(name)
        set(name, *args, &block)
      end
    end

    set :default_shell do
      shell = File.join(rvm_bin_path, "rvm-shell")
      ruby = rvm_ruby_string.to_s.strip
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

    # Use the default ruby on the server, by default :)
    _cset(:rvm_ruby_string, "default")

    # Default sudo state
    _cset(:rvm_install_with_sudo, false)

    # Let users set the install type and shell of their choice.
    _cset(:rvm_install_type, :stable)
    _cset(:rvm_install_shell, :bash)

    # Let users set the (re)install for ruby.
    _cset(:rvm_install_ruby, :install)
    _cset(:rvm_install_ruby_threads, "$(cat /proc/cpuinfo | grep vendor_id | wc -l)")

    # Pass no special params to the ruby build by default
    _cset(:rvm_install_ruby_params, '')

    namespace :rvm do
      desc <<-EOF
        Install RVM of the given choice to the server.
        By default RVM "stable" is installed, change with:

        set :rvm_install_type, :head

        By default BASH is used for installer, change with:

        set :rvm_install_shell, :zsh
      EOF
      task :install_rvm do
        command_curl_start = <<-EOF.gsub(/^\s*/, '')
          export CURL_HOME=${TMPDIR:-${HOME}}/.rvm-curl-config;
          mkdir ${CURL_HOME}/;
          {
            [[ -r ${HOME}/.curlrc ]] && cat ${HOME}/.curlrc;
            echo "silent";
            echo "show-error";
          } > $CURL_HOME/.curlrc
        EOF
        command_curl_end = "rm -rf $CURL_HOME"
        command_fetch    = "curl -L get.rvm.io"
        command_install  = case rvm_type
          when :root, :system
            if fetch(:use_sudo, true) == false && rvm_install_with_sudo == false
              raise ":use_sudo is set to 'false' but sudo is needed to install rvm_type: #{rvm_type}. You can enable use_sudo within rvm for use only by this install operation by adding to deploy.rb: set :rvm_install_with_sudo, true"
            else
              "#{sudo} "
            end
          else
            ''
          end
        command_install << "#{rvm_install_shell} -s #{rvm_install_type} --path #{rvm_path}"
        _command = <<-EOF
          #{command_curl_start};
          #{command_fetch} | #{command_install};
          #{command_curl_end}
        EOF
        run "#{_command}".gsub(/[\s\n]+/, ' '), :shell => "#{rvm_install_shell}"
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
      task :install_ruby do
        ruby, gemset = rvm_ruby_string.to_s.strip.split /@/
        if %w( release_path default ).include? "#{ruby}"
          raise "ruby can not be installed when using :rvm_ruby_string => :#{ruby}"
        else
          run "#{File.join(rvm_bin_path, "rvm")} #{rvm_install_ruby} #{ruby} -j #{rvm_install_ruby_threads} #{rvm_install_ruby_params}", :shell => "#{rvm_install_shell}"
          if gemset
            run "#{File.join(rvm_bin_path, "rvm")} #{ruby} do rvm gemset create #{gemset}", :shell => "#{rvm_install_shell}"
          end
        end
      end

      desc "Create gemset"
      task :create_gemset do
        ruby, gemset = rvm_ruby_string.to_s.strip.split /@/
        if %w( release_path default ).include? "#{ruby}"
          raise "gemset can not be created when using :rvm_ruby_string => :#{ruby}"
        else
          if gemset
            run "#{File.join(rvm_bin_path, "rvm")} #{ruby} do rvm gemset create #{gemset}", :shell => "#{rvm_install_shell}"
          end
        end
      end

      desc "Install a gem, 'cap rvm:install_gem GEM=my_gem'."
      task :install_gem do
        run "#{File.join(rvm_bin_path, "rvm")} #{rvm_ruby_string} do gem install #{ENV['GEM']}", :shell => "#{rvm_install_shell}"
      end

      desc "Uninstall a gem, 'cap rvm:uninstall_gem GEM=my_gem'."
      task :uninstall_gem do
        run "#{File.join(rvm_bin_path, "rvm")} #{rvm_ruby_string} do gem uninstall --no-executables #{ENV['GEM']}", :shell => "#{rvm_install_shell}"
      end

    end
  end if const_defined? :Configuration
end

# E.g, to use ree and rails 3:
#
#   require 'rvm/capistrano'
#   set :rvm_ruby_string, "ree@rails3"
#

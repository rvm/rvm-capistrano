require 'rvm/capistrano/helpers/_cset'
require 'rvm/capistrano/helpers/rvm_methods'

rvm_with_capistrano do

  deferred_load do
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

    # Let users set the type of their rvm install.
    _cset(:rvm_type, :user)

    # Define rvm system and user paths
    # This is used in the default_shell command to pass the required variable to rvm-shell, allowing
    # rvm to boostrap using the proper path.  This is being lost in Capistrano due to the lack of a
    # full environment.
    _cset(:rvm_system_path, "/usr/local/rvm")
    _cset(:rvm_user_path,   "$HOME/.rvm")

    _cset(:rvm_path) do
      case rvm_type
      when :root, :system
        rvm_system_path
      when :local, :user, :default
        rvm_user_path
      else
        rvm_type.to_s.empty? ? rvm_user_path : rvm_type.to_s
      end
    end

    # Let users override the rvm_bin_path
    _cset(:rvm_bin_path) { "#{rvm_path}/bin" }

    # Let users configure a path to export/import gemsets
    _cset(:rvm_gemset_path) do
      case rvm_type
      when :root, :system, :local, :user, :default
        rvm_path
      else
        rvm_path
      end + "/gemsets"
    end
    # evaluate :rvm_ruby_string => :local
    set :rvm_ruby_string_evaluated do
      value = fetch(:rvm_ruby_string, :default)
      if value.to_sym == :local
        value = ENV['GEM_HOME'].gsub(/.*\//,"")
      end
      value.to_s
    end

    # Use the default ruby on the server, by default :)
    _cset(:rvm_ruby_string, :default)

  end

## not needed in base but are used in many extensions

  deferred_load do
    # Let users set the install shell of their choice
    _cset(:rvm_install_shell, :bash)
  end

  extend Capistrano::RvmMethods

  namespace :rvm do
    extend Capistrano::RvmMethods
  end

end

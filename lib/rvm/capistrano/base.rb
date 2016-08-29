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
      when "latest_release"
        latest_release_path = exists?(:deploy_timestamped) ? release_path : current_path
        shell = "rvm_path=#{rvm_path} #{shell} --path '#{latest_release_path}'"
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
    _cset(:rvm_user, [])
    if rvm_type == :mixed
      abort "When rvm_type is :mixed, you must also set rvm_user." if rvm_user.empty?
      abort "rvm_user must be an Array of values, e.g. [ :gemsets ]" unless rvm_user.is_a? Array
      valid = [ :gemsets, :rubies, :hooks, :pkgs, :wrappers ]
      invalid = rvm_user - valid - [:all, :none ]
      abort "Invalid value(s) in rvm_user: " + invalid.join(', ') unless invalid.empty?
      if rvm_user.size > 1
        abort "rvm_user cannot mix :none with other values." if rvm_user.include? :none
        abort "rvm_user cannot mix :all with other values."  if rvm_user.include? :all
      elsif rvm_user == [ :all ]
        set(:rvm_user) { valid }
      end
    else
      if ! rvm_user.empty?
        abort "rvm_user must not be set unless rvm_type is :mixed (was #{rvm_user})."
      end
    end

    # Define rvm system and user paths
    # This is used in the default_shell command to pass the required variable to rvm-shell, allowing
    # rvm to boostrap using the proper path.  This is being lost in Capistrano due to the lack of a
    # full environment.
    _cset(:rvm_system_path, "/usr/local/rvm")
    _cset(:rvm_user_path,   "$HOME/.rvm")

    _cset(:rvm_path) do
      case rvm_type
      when :root, :system, :mixed
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
      when :mixed
        rvm_user.include?(:gemsets) ? rvm_user_path : rvm_system_path
      else
        rvm_path
      end + "/gemsets"
    end
    # evaluate :rvm_ruby_string => :local
    set :rvm_ruby_string_evaluated do
      value = fetch(:rvm_ruby_string, :default)
      if value.to_sym == :local
        if ENV['RBENV_VERSION']
          gem_set = ENV['GEM_HOME'].to_s.match(/(?:\/gemsets\/(.*))$/).to_a[1]
          value = [ENV['RBENV_VERSION'], gem_set].compact.join("@")
        else
          value = ENV['GEM_HOME'].gsub(/.*\//,"")
        end
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

require 'rvm/capistrano/base'
require 'rvm/capistrano/helpers/run_silent_curl'
require 'rvm/capistrano/helpers/rvm_if_sudo'

rvm_with_capistrano do

  deferred_load do

    # Let users set the install type of their choice.
    _cset(:rvm_install_type, :stable)

    _cset(:rvm_install_url, "https://get.rvm.io")

    # By default system installations add deploying user to rvm group. also try :all
    _cset(:rvm_add_to_group, fetch(:user,"$USER"))

  end

  namespace :rvm do

    desc <<-EOF
      Install RVM of the given choice to the server.
      By default RVM "stable" is installed, change with:

      set :rvm_install_type, :head

      By default BASH is used for installer, change with:

      set :rvm_install_shell, :zsh
    EOF
    rvm_task :install_rvm do
      command_fetch    = "curl -L #{rvm_install_url}"
      command_install  = rvm_if_sudo(:subject_class => :rvm)
      command_install << "#{rvm_install_shell} -s #{rvm_install_type} --path #{rvm_path}"
      case rvm_type
      when :root, :system
        command_install << " --add-to-rvm-group #{[rvm_add_to_group].flatten.map(&:to_s).join(",")}"
      end
      run_silent_curl "#{command_fetch} | #{command_install}"
    end

  end

end

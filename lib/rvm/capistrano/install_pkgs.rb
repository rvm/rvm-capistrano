require 'rvm/capistrano/base'

rvm_with_capistrano do

  warn "task 'rvm:install_pkgs' is deprecated, please read about autolibs => http://rvm.io/rvm/autolibs especially check the autolibs mode 'rvm_pkg'."

  deferred_load do

    # Additional rvm packages to install.
    _cset(:rvm_install_pkgs, [])

  end

  namespace :rvm do

    desc <<-EOF
      WARNING: Deprecated, please read about autolibs => http://rvm.io/rvm/autolibs especially check the autolibs mode 'rvm_pkg'.

      Install RVM packages to the server.

      This must come before the 'rvm:install_ruby' task is called.

      The package list is empty by default.  Specifiy the packages to install with:

      set :rvm_install_pkgs, %w[libyaml curl]

      Full list of packages available at https://rvm.io/packages/ or by running 'rvm pkg'.
    EOF

    rvm_task :install_pkgs do
      rvm_install_pkgs.each do |pkg|
        run_rvm("pkg install #{pkg}")
      end
    end

  end

end

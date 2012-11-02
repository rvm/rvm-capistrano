# rvm-capistrano

https://rvm.io/integration/capistrano/#gem

## Description

RVM / Capistrano Integration Gem

## Installation

RVM / Capistrano integration is available as a separate gem

    $ gem install rvm-capistrano

Or, if the **capistrano** gem is aleady in your `Gemfile`, then add **rvm-capistrano**:

    $ echo "gem 'rvm-capistrano'" >> Gemfile
    $ bundle install


## Example

The following code will:

- detect `ruby@gemset` used for deployment
- install RVM and Ruby on `cap deploy:setup`

Example:

    set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
    set :rvm_install_ruby_params, '--1.9'      # for jruby/rbx default to 1.9 mode
    set :rvm_install_pkgs, %w[libyaml openssl] # package list from https://rvm.io/packages
    set :rvm_install_ruby_params, '--with-opt-dir=/usr/local/rvm/usr' # package support

    before 'deploy:setup', 'rvm:install_rvm'   # install RVM
    before 'deploy:setup', 'rvm:install_pkgs'  # install RVM packages before Ruby
    before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
    before 'deploy:setup', 'rvm:create_gemset' # only create gemset
    before 'deploy:setup', 'rvm:import_gemset' # import gemset from file

    require "rvm/capistrano"


## To use the ruby version currently active locally

    set :rvm_ruby_string, :local

## Tasks

```bash
$ cap -T rvm
cap rvm:create_gemset        # Create gemset
cap rvm:export_gemset        # Export the current RVM ruby gemset contents to a file.
cap rvm:import_gemset        # Import file contents to the current RVM ruby gemset.
cap rvm:install_ruby         # Install RVM ruby to the server, create gemset ...
cap rvm:install_rvm          # Install RVM of the given choice to the server.
cap rvm:install_pkgs         # Install RVM packages to the server.
cap rvm:install_gem   GEM=my_gem  # Install gem {my_gem} on the server using selected ruby.
cap rvm:uninstall_gem GEM=my_gem  # Uninstall gem {my_gem} from the server selected ruby.
```

## Development

    $ rake spec

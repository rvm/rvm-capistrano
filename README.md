# rvm-capistrano

https://rvm.io/integration/capistrano/#gem

## Description

RVM / Capistrano Integration Gem

## Installation

RVM / Capistrano integration is available as a separate gem

```bash
$ gem install rvm-capistrano
```

Or, if the **capistrano** gem is aleady in your `Gemfile`, then add **rvm-capistrano**:

```bash
$ echo "gem 'rvm-capistrano'" >> Gemfile
$ bundle install
```

## Example

The following code will:

- detect `ruby@gemset` used for deployment
- install RVM and Ruby on `cap deploy:setup`

Example:

```ruby
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
```

### To use the ruby version currently active locally

```ruby
set :rvm_ruby_string, :local
```

### To restrict rvm to only `:app` servers

Warning, when using `:rvm_require_role` `parallel` is used to select shell per server instead of `:default_shell`

```ruby
set :rvm_require_role, :app
require "rvm/capistrano"
```

The order is important `:rvm_require_role` has to be `set` before `require "rvm/capistrano"`.

### To restrict rvm to only some servers

```ruby
set :rvm_require_role, :rvm
require "rvm/capistrano"
role :rvm, "web1", "web2"
role :app, "web1", "web2", "web3"
```

### To control rvm shell manually

```ruby
require "rvm/capistrano"
set :default_shell, :bash
task :example do
  run "echo 'in rvm'", :shell => fetch(:rvm_shell)
end
```

### Disable rvm shell for single command

```ruby
task :example do
  run "echo 'not in rvm'", :shell => :bash
end
```

## Options

- `:rvm_ruby_string` - which ruby should be loaded
 - `release_path` - load ruby defined in `#{release_path}` - Capistrano variable pointing where code is checked out
 - `local` - detect local machine running ruby using `GEM_HOME`
 - `<ruby-version>` - specify ruby version to use

- `:rvm_type` - how to detect rvm, default `:user`
 - `:user` - RVM installed in `$HOME`, user installation (default)
 - `:system` - RVM installed in `/usr/local`, multiuser installation

- `:rvm_path` - force `$rvm_path`, only overwrite if standard paths can not be used
- `:rvm_bin_path` - force `$rvm_bin_path`, only overwrite if standard paths can not be used
- `:rvm_gemset_path` - storage for gem lists files for exporting/importing, by default `$rvm_path/gemsets`
- `:rvm_install_with_sudo` - when set to `true` forces RVM installation with `sudo` even `:use_sudo` is set to `false`

- `:rvm_install_type` - version of RVM to install, by default `stable`
 - `stable` - stable version of RVM
 - `head` - head version of RVM (development)
 - `latest-1.18` - latest version of RVM 1.18.x
 - `1.18.4` - selected version

- `:rvm_install_shell` - shell to be used for `rvm` operations, by default `bash`, most likely you do not need to change it
- `:rvm_install_ruby` - a command used to install ruby, by default `install`, most likely you do not need to change it
- `:rvm_install_ruby_threads` - number of threads to use for ruby compilation, by default it's number of CPU cores on Linux
- `:rvm_install_ruby_params` - parameters for ruby, example `--patch railsexpress`
- `:rvm_install_pkgs` - array of packages to install with `cap rvm:install_pkgs`
- `:rvm_add_to_group` - user name to add to `rvm` group when RVM is installed with `:rvm_type` `:system`, by default it's the user name that runs deploy

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

# rvm-capistrano

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
set :rvm_ruby_string, :local               # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"        # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, OR:
before 'deploy:setup', 'rvm:create_gemset' # only create gemset

require "rvm/capistrano"
```

### RVM + Ruby on every deploy

Update RVM and make sure Ruby is installed on every deploy:

```ruby
set :rvm_ruby_string, :local        # use the same ruby as used locally for deployment

before 'deploy', 'rvm:install_rvm'  # update RVM
before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)

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

- `:rvm_autolibs_flag` - control autolibs, read more `rvm help autolibs`
 - `:disable` - fully disable autolibs, limit automated tasks
 - `:read`    - autolibs only in read only mode, do not change anything in system
 - `:fail`    - autolibs only in read only mode, fail if changes are required
 - `:enable`  - let RVM install what is needed for ruby, required `set :use_sudo, true`

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

- `:rvm_require_role` - allows using RVM for only one role, useful when database is separated, it has to be defined before `require 'rvm/capistrano'`
 - `:app` - use RVM only on servers defined for role `:app`
 - `:rvm` - use RVM only on servers defined for role `:rvm` - where not all `:app` servers support RVM
 - `<role>` - any other role that is defining servers supporting RVM

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
                                  # Use `ENV['GEM'] = "bundler"` in script to specify gems.
cap rvm:uninstall_gem GEM=my_gem  # Uninstall gem {my_gem} from the server selected ruby.
```

## Development

SM Framework extension for gem development:

    $ curl -L https://get.smf.sh | sh
    $ sm ext install gem mpapis/sm_gem
    $ sm gem --help

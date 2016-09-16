# rvm-capistrano

## Description

RVM / Capistrano Integration Gem

## Compatibility

- `rvm-capistrano` `1.3.0` with Autolibs requires at least RVM `1.19.0`.
- `capistrano` `3.0.0` is a rewrite and does not work with this gem, use [`rvm1/capistrano3`](https://github.com/rvm/rvm1-capistrano3#readme) it will be extended to match this gem functionality.

## Installation

RVM / Capistrano integration is available as a separate gem

```bash
$ gem install rvm-capistrano
```

Or, if the **capistrano** gem is already in your `Gemfile`, then add **rvm-capistrano**:

```bash
$ echo "gem 'rvm-capistrano'" >> Gemfile
$ bundle install
```

## Modules

Since version `1.4.0` `rvm-capistrano` is divided into separate
modules which allow selecting which parts of it should be included.

`rvm/capistrano`:

- `base`     - minimal code, does not change behaviors, only provides definitions like `:rvm_shell`
- `selector` - extends `base` to automatically `set :default_shell`
- `selector_mixed` - alternative version of `selector` allowing to select which servers should be RVM aware
- `info_list`      - adds tasks `rvm:info`, `rvm:list` and `rvm:info_list`
- `install_rvm`    - adds task `rvm:install_rvm` - it also updates rvm if already installed
- `install_ruby`   - adds task `rvm:install_ruby`
- `create_gemset`  - adds task `rvm:create_gemset`
- `empty_gemset`   - adds task `rvm:empty_gemset`
- `install_pkgs`   - adds task `rvm:install_pkgs` - **deprecated** (you should try `autolibs` first)
- `gem_install_uninstall` - adds tasks `rvm:install_gem`   / `rvm:uninstall_gem`
- `gemset_import_export`  - adds tasks `rvm:import_gemset` / `rvm:export_gemset`
- `alias_and_wrapp`       - adds tasks `rvm:create_alias`  / `rvm:create_wrappers` / `rvm:show_alias_path`

By default `rvm/capistrano` loads: `selector`, `info_list`, `install_rvm`, `install_ruby`, `create_gemset`.

Warning: `selector` and `selector_mixed` are to be used separately they can not be used both at the same time.

## Requiring

Minimal code to load this gem is:

```ruby
require "rvm/capistrano"
```

Usually it's placed in `config/deploy.rb`.

## Example

The following code will:

- detect `ruby@gemset` used for deployment
- install RVM and Ruby on `cap deploy:setup`

Example:

```ruby
require "rvm/capistrano"

set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR:
# before 'deploy:setup', 'rvm:create_gemset' # only create gemset
```

### Disabling `bundle --deployment` when using gemsets

Using gemsets is safer from `bundle --deployment` which is default, to disable it use:

```ruby
set :bundle_dir, ''
set :bundle_flags, '--system --quiet'
```

### RVM + Ruby on every deploy

Update RVM and make sure Ruby is installed on every deploy:

```ruby
require "rvm/capistrano"

set :rvm_ruby_string, :local        # use the same ruby as used locally for deployment

before 'deploy', 'rvm:install_rvm'  # install/update RVM
before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)
```

### Create application alias and wrappers

For server scripts and configuration the easiest is to use wrappers from aliased path.

```ruby
require "rvm/capistrano/alias_and_wrapp"
before 'deploy', 'rvm:create_alias'
before 'deploy', 'rvm:create_wrappers'
```
To see the path to be used in scripts use:
```bash
cap rvm:show_alias_path
```
It will show either that the path does not exist yet:
```ruby
*** [err :: niczsoft.com] ls: cannot access /home/ad/.rvm//wrappers/ad/*: No such file or directory
```
or in case it exist it will list all available wrappers:
```
...
 ** [out :: niczsoft.com] /home/ad/.rvm//wrappers/ad/ruby
...
```
This will allow to use clean scripts where proper RVM settings are automatically loaded
from the aliased wrappers. For example configuring
[PassengerRuby](http://www.modrails.com/documentation/Users%20guide%20Apache.html#PassengerRuby)
with `/home/ad/.rvm//wrappers/ad/ruby`, this way there is no need for changing scripts
when the application ruby changes. In the same spirit you can use wrapper for `bundle`
in **cron** or **init.d** scripts with `/home/ad/.rvm//wrappers/ad/bundle exec [command]` -
it will automatically load proper configuration for the application, no need for any tricks.

### To use the ruby version currently active locally

```ruby
set :rvm_ruby_string, :local
```

### To restrict rvm to only `:app` servers

Warning, when using `:rvm_require_role` `parallel` is used to select shell per server instead of `:default_shell`

```ruby
set :rvm_require_role, :app
require "rvm/capistrano/selector_mixed"
```

It is important to `set :rvm_require_role` before `require "rvm/capistrano/selector_mixed"`.

### To restrict rvm to only some servers

```ruby
set :rvm_require_role, :rvm
require "rvm/capistrano/selector_mixed"
role :rvm, "web1", "web2"
role :app, "web1", "web2", "web3"
```

### To control rvm shell manually

```ruby
require "rvm/capistrano/base"
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

### Show info on remote rvm and list rubies

```bash
cap rvm:info_list
```

## Options

- `:rvm_ruby_string` - which ruby should be loaded
 - `release_path` - load ruby defined in `#{release_path}` - Capistrano variable pointing where code is checked out
 - `latest_release` - load ruby defined in `#{release_path}`, if it exists, or `#{current_path}`
 - `local` - detect local machine running ruby using `GEM_HOME`
 - `<ruby-version>` - specify ruby version to use

- `:rvm_type` - how to detect rvm, default `:user`
 - `:user` - RVM installed in `$HOME`, user installation (default)
 - `:system` - RVM installed in `/usr/local`, multiuser installation
 - (some other values permitted for backwards compatability only)

- `:rvm_user` - arguments to pass to `rvm user`, to enable mixed mode (e.g. system rubies and user gemsets).  Based on whether rvm_user includes :gemsets it also helps determine the correct path for importing/exporting gemsets, and similarly, whether to use sudo for gemset creation/deletion and other operations.
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
- `:rvm_install_ruby_threads` - number of threads to use for ruby compilation, rvm by default uses all CPU cores
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
cap rvm:info                 # Show rvm info
cap rvm:info_list            # Show info and list rubies
cap rvm:list                 # List rvm rubies
cap rvm:install_ruby         # Install RVM ruby to the server, create gemset ...
cap rvm:install_rvm          # Install/update RVM of the given choice to the server.
cap rvm:install_pkgs         # Install RVM packages to the server.
cap rvm:install_gem   GEM=my_gem  # Install gem {my_gem} on the server using selected ruby.
                                  # Use `ENV['GEM'] = "bundler"` in script to specify gems.
cap rvm:uninstall_gem GEM=my_gem  # Uninstall gem {my_gem} from the server selected ruby.
cap rvm:create_alias         # create #{application} alias
cap rvm:create_wrappers      # create wrappers for gem executables
cap rvm:show_alias_path      # show path to aliased path with wrappers
```

## Development

SM Framework extension for gem development:

    $ curl -L https://get.smf.sh | sh
    $ sm ext install gem mpapis/sm_gem
    $ sm gem --help

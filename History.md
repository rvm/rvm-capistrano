### 1.5.3 / 2014-06-27

* Fix defined? check on ENV, merged #101 by @themilkman

### 1.5.2 / 2014-05-31

* Documentation updates #96, #98
* Use RUBY_VERSION when available for autodetecting the version, merged #99 by @naemono

### 1.5.1 / 2013-10-08

* Fix curl silencing #91 by @aspiers

### 1.5.0 / 2013-09-04

* Add rvm:info & rvm:list for easier debugging

### 1.5.0.rc1 / 2013-08-18

* Thanks to @aspiers for the great work:
* add tests
* add mixed mode support
* add support for disabling `sudo` based on `:subject_class`

### 1.4.4 / 2013-08-14

* cleaning, merge #83

### 1.4.3 / 2013-08-09

* move command_with_shell to common code, fix #82

### 1.4.2 / 2013-08-09

* require newer capistrano - fix issue with rails 4, merge #81

### 1.4.1 / 2013-07-13

* add tasks to create aliases and wrappers, closes #77

### 1.4.0 / 2013-07-09

* fix configuration deffering for requiring rvm/capistrano from a task, fix #76
* merge empty_gemset, merge #60
* extact extensions, update #60

### 1.3.4 / 2013-06-28

* fix semicolons in with_rvm_group, fix #73
* allow setting variables after reqired, fix parenthises warings, remove old rvm_install_ruby_threads

### 1.3.3 / 2013-06-26

* mention how to disble bundle --deploymnt, closes #72
* use sg only if needed and deferr sudo check for itto console, fix #71

### 1.3.2 / 2013-06-24

* extract sudo handling code into single function, fix #71

### 1.3.1 / 2013-06-10

* prefix sg with sudo, fix #69
* documentation / spelling fixes

### 1.3.0 / 2013-04-12

* Silence curl progress when fetching libyaml, Ruby, etc. during rvm:install_ruby, closes #33
* Fix concurrency issue when running on shared home directory, merge #39
* Add support for rvm pkg install, gemset import/export, closes #40
* Make sure deploying user is added to rvm group, fix #43
* Fix retun status of silent curl, fix #37
* Allow restricting rvm tasks to given roles, closes #42
* Fix rvm_install_ruby_threads when there is no /proc/cpuinfo, fix #46
* Default :rvm_install_pkgs to [], fix #44
* Improved checking if capistrano was loaded, fix #30
* Fix parameters ordering for creating gemsets, fix #49
* Allow setting :local ruby string to read version/gemset from GEM_HOME, fix #50
* Defer setting rvm_shell and default_shell, fix #51
* Improved error messages
* Improved documentation

### 1.2.7 / 2012-09-09

* add rvm:(un)install_gem, merged #32

### 1.2.6 / 2012-08-28

* fix undefined use_sudo, merged #32

### 1.2.5 / 2012-07-17

* silence `rvm:rvm_install`, closes #22

### 1.2.4 / 2012-07-17

* fix detecting Capistrano constant in Ruby 1.8.7, fix #28, closes #23

### 1.2.3 / 2012-07-07

* Add LICENSE, merged #14
* Only load code if the Capistrano constant is defined, fix #23, merged #26

### 1.2.2 / 2012-05-24

* Default `rvm_install_ruby_params` to an empty string - fixes #15

### 1.2.1 / 2012-05-22

* Add `set :rvm_ruby_string, :local`, merged #4
* Fix `command_install` edge cases, merged #12, closes #13

### 1.2.0 / 2012-05-19

* Add task to create gemset, fix #8
* Add `rvm_install_ruby_params`, fix #9
* Improved installing RVM with sudo, fix #10
* Use the new RVM installer

### 1.1.0 / 2012-04-29

* Fix rvm installation task to use sudo and `rvm_path` when needed

### 1.0.2 / 2012-03-28

* Fix the bundler auto require problem

### 1.0.1 / 2012-03-26

* Updated to latest integration code for installing rvm/ruby
* Cleaning code, improving gemification
* Switch the default rvm installation type to user - as we discourage system installations
* Improved README.md

### 1.0.0 / 2012-03-26

* Ported RVM /Capistrano Gem Library into it's own repository from the main RVM
  repostitory. ( https://github.com/wayneeseguin/rvm-capistrano )

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

## 1.2.0 / 2012-05-19

* Add task to create gemset, fix #8
* Add `rvm_install_ruby_params`, fix #9
* Improved installing RVM with sudo, fix #10
* Use the new RVM installer

## 1.1.0 / 2012-04-29

* Fix rvm installation task to use sudo and `rvm_path` when needed

### 1.0.2 / 2012-03-28

* Fix the bundler auto require problem

### 1.0.1 / 2012-03-26

* Updated to latest integration code for installing rvm/ruby
* Cleaning code, improving gemification
* Switch the default rvm installation type to user - as we discourage system installations
* Improved README.md

# 1.0.0 / 2012-03-26

* Ported RVM /Capistrano Gem Library into it's own repository from the main RVM
  repostitory. ( https://github.com/wayneeseguin/rvm-capistrano )

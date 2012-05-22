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

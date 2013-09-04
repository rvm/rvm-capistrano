# Recipes for using RVM on a server with capistrano.

require 'rvm/capistrano/selector'
require 'rvm/capistrano/info_list'
require 'rvm/capistrano/install_rvm'
require 'rvm/capistrano/install_ruby'
require 'rvm/capistrano/create_gemset'

# E.g, to use ree and rails 3:
#
#   require 'rvm/capistrano'
#   set :rvm_ruby_string, "ree@rails3"

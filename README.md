# rvm-capistrano

https://rvm.beginrescueend.com/integration/capistrano

## Description

RVM / Capistrano Integration Gem

## Installation

RVM / Capistrano integration is now available as a separate gem

    $ gem install rvm-capistrano

## Example

The following code will:

- detect `ruby@gemset` used for deployment
- install RVM and Ruby on `cap deploy:detup`

Example:

    set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
    
    before 'deploy:setup', 'rvm:install_rvm'
    before 'deploy:setup', 'rvm:install_ruby'
    
    require "rvm/capistrano"


## Development

    $ rake spec

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
- install RVM and Ruby on `cap deploy:setup`

Example:

    set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
    
    before 'deploy:setup', 'rvm:install_rvm'   # install RVM
    before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
    before 'deploy:setup', 'rvm:create_gemset' # only create gemset
    
    require "rvm/capistrano"


## Development

    $ rake spec

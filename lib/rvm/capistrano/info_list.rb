require 'rvm/capistrano/base'
require 'rvm/capistrano/helpers/with_rvm_group'

rvm_with_capistrano do
  namespace :rvm do

    desc "Show rvm info"
    rvm_task :info do
      run_rvm("info")
    end

    desc "List rvm rubies"
    rvm_task :list do
      run_rvm("list")
    end

    desc "Show info and list rubies"
    task :info_list do
      info
      list
    end
  end
end

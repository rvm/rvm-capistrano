require 'rvm/capistrano/base'

rvm_with_capistrano do
  deferred_load do

    # conflicts with rvm/capistrano/selector_mixed
    unless fetch(:rvm_require_role,nil).nil?
      raise "

  ERROR: found: 'set :rvm_require_role, \"#{fetch(:rvm_require_role,nil)}\"',
         it conflicts with 'require \"rvm/capistrano/selector\"',
         please remove it.

  "
    end

    set :default_shell do
      fetch(:rvm_shell)
    end

  end
end

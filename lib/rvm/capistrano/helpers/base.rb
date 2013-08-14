module Capistrano
  class Configuration
    def deferred_load(&block)
      if current_task
        instance_eval(&block)
      else
        on(:load, &block)
      end
    end
  end
end

def rvm_with_capistrano(&block)
  if Capistrano.const_defined?(:Configuration) &&
      Capistrano::Configuration.methods.map(&:to_sym).include?(:instance)
    Capistrano::Configuration.instance(true).load(&block)
  end
end

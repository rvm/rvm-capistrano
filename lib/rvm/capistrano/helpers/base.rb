module Capistrano
end

def rvm_with_capistrano(&block)
  if Capistrano.const_defined? :Configuration and Capistrano::Configuration.methods.map(&:to_sym).include? :instance
    Capistrano::Configuration.instance(true).load(&block)
  end
end

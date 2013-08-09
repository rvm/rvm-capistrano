require 'rvm/capistrano/base'
require 'rvm/capistrano/helpers/quote_and_escape'

rvm_with_capistrano do

  if fetch(:rvm_require_role,nil).nil?
    raise "

ERROR: no 'set :rvm_require_role, \"...\"' declared before 'rvm/capistrano/selector_mixed',
       it is required for proper functioning, please add it and try again.

"
  end

  # conflicts with rvm/capistrano/selector
  class << self
    def run(cmd, options={}, &block)
      if options[:eof].nil? && !cmd.include?(sudo)
        options = options.merge(:eof => !block_given?)
      end
      shell = options[:shell]
      options[:shell] = false

      parallel(options) do |session|
        if shell.nil?
          session.when "in?(:#{fetch(:rvm_require_role,nil)})", command_with_shell(cmd, fetch(:rvm_shell)), &block
        end
        session.else command_with_shell(cmd, shell), &block
      end
    end

  end
end

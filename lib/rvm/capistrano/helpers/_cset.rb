require 'rvm/capistrano/helpers/base'

rvm_with_capistrano do

  unless methods.map(&:to_sym).include?(:_cset)
    # Taken from the capistrano code.
    def _cset(name, *args, &block)
      unless exists?(name)
        set(name, *args, &block)
      end
    end
  end

end

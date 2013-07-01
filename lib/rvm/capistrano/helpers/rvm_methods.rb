module Capistrano
  module RvmMethods
    # defined depending on which selector was used
    def rvm_task(name,&block)
      if fetch(:rvm_require_role,nil).nil?
        task name, &block
      else
        task name, :roles => fetch(:rvm_require_role), &block
      end
    end

    # allow running tasks without using rvm_shell
    def run_without_rvm(command)
      run command, :shell => "#{rvm_install_shell}"
    end

    # allow running tasks with forcing rvm_shell
    def run_with_rvm(command)
      run command, :shell => "#{rvm_shell}"
    end

    # shortcut to binary rvm #{command}
    # - use :with_rvm_group => true - to wrap it all in `with_rvm_group(...)` call
    # - use :with_ruby => 'with_ruby' - to extend to `.../bin/rvm #{with_ruby} do`
    def run_rvm(command, options={})
      if options[:with_rvm_group]
        run_without_rvm("#{path_to_bin_rvm(options)} #{command}")
      else
        run_without_rvm(with_rvm_group("#{path_to_bin_rvm(options)} #{command}"))
      end
    end

    # helper to find path to rvm binary
    def path_to_bin_rvm(options={})
      result = File.join(rvm_bin_path, "rvm")
      result << " #{options[:with_ruby]} do" if options[:with_ruby]
      result
    end
  end
end

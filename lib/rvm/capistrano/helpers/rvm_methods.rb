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
    # - use :subject_class => :gemsets to indicate that the subject of the operation
    #     will be a gemset; valid values are any values which can be contained in
    #     the rvm_user config variable Array.  This allows us to determine whether
    #     the subject is persisted system-wide or just per-user, and as a result
    #     whether sudo is required.
    def run_rvm(command, options={})
      rvm_bin = path_to_bin_rvm(options)
      cmd = "#{rvm_bin} #{command}"
      cmd = with_rvm_group(cmd, options) if options[:with_rvm_group]
      cmd = rvm_user_command(options) + cmd
      run_without_rvm(cmd)
    end

    # If we're operating on something affected by the rvm user mode,
    # we need to make sure that the server has the right rvm user mode.
    # This returns a shell command to prepend to an existing command
    # in order to achieve this.
    def rvm_user_command(options={})
      return '' unless rvm_type == :mixed && options[:subject_class]
      rvm_user_args = rvm_user.empty? ? 'none' : rvm_user.map(&:to_s).join(' ')
      rvm_bin = path_to_bin_rvm({ :with_ruby => true }.merge(options))
      "#{rvm_bin} rvm user #{rvm_user_args} ; "
    end

    # helper to find path to rvm binary
    def path_to_bin_rvm(options={})
      result = File.join(rvm_bin_path, "rvm")
      result << " #{options[:with_ruby]} do" if options[:with_ruby]
      result
    end

    def command_with_shell(cmd, shell=nil)
      if shell == false
        cmd
      else
        "#{shell || "sh"} -c #{quote_and_escape(cmd)}"
      end
    end
  end
end

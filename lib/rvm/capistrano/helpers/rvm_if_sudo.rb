require 'rvm/capistrano/base'

rvm_with_capistrano do

  deferred_load do
    # Default sudo state
    _cset(:rvm_install_with_sudo, false)
  end

  def rvm_if_sudo(options = {})
    return '' unless need_root(options)
    prohibited = sudo_prohibited(options)
    return prohibited if prohibited # will cause a deferred error
    return "#{sudo} "
  end

  def need_root(options = {})
    return true if rvm_type == :root || rvm_type == :system
    return false unless rvm_type == :mixed # must be user installation

    # Finally deal with mixed installations.  Whether we need sudo
    # depends on what we're trying to do.
    # If rvm_user config variable contains :gemsets (say), and we're
    # operating on gemsets, then we don't need root.  However, the
    # most common use case for sudo is for installing rubies, so we
    # default to that to keep the code simpler.
    options[:subject_class] ||= :rubies

    # rvm is installed system-wide in mixed installations
    return true if options[:subject_class] == :rvm

    return ! rvm_user.include?(options[:subject_class])
  end

  def sudo_prohibited(options = {})
    return false if fetch(:use_sudo, true) || rvm_install_with_sudo

    explanation = <<-EXPLANATION
You can enable use_sudo within rvm for use only by this install operation by adding to deploy.rb:

    set :rvm_install_with_sudo, true

    EXPLANATION

    if options[:deferred]
      <<-DEFERRED_ERROR.gsub(/\n/, " ; ")
echo "
Neither :use_sudo or :rvm_install_with_sudo was set and installation would ended up in using 'sudo'
#{explanation}
" >&2
exit 1
      DEFERRED_ERROR
    else
      raise "

:use_sudo is set to 'false' but sudo is needed to install rvm_type: #{rvm_type}.
#{explanation}
"
    end
  end

end

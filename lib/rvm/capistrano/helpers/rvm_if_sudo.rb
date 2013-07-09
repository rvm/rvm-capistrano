require 'rvm/capistrano/base'

rvm_with_capistrano do

  deffered_load do
    # Default sudo state
    _cset(:rvm_install_with_sudo, false)
  end

  def rvm_if_sudo(options = {})
    case rvm_type
    when :root, :system
      if fetch(:use_sudo, true) == false && rvm_install_with_sudo == false
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
      else
        "#{sudo} "
      end
    else
      ''
    end
  end

end

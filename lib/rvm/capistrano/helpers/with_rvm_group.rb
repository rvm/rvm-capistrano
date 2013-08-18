require 'rvm/capistrano/helpers/base'
require 'rvm/capistrano/helpers/rvm_if_sudo'
require 'rvm/capistrano/helpers/quote_and_escape'

rvm_with_capistrano do

  def with_rvm_group(command, options = {})
    if need_root(options)
      rvm_user_command + <<-CODE
if id | grep ' groups=.*(rvm)' >/dev/null ;
then #{command} ;
else #{rvm_if_sudo(options.merge(:deferred => true))} sg rvm -c #{quote_and_escape(command)} ;
fi
      CODE
    else
      command
    end
  end

end

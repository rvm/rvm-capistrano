require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "rvm:create_gemset task" do
  include_context "Capistrano::Configuration"

  before {
    @configuration.require 'rvm/capistrano/empty_gemset'
    @gemset = 'mygemset'
    @configuration.set :rvm_ruby_string, '2.0.0@' + @gemset
    @task = @configuration.find_task 'rvm:empty_gemset'
  }

  it "should empty a gemset in $HOME" do
    @configuration.trigger :load
    expected = "$HOME/.rvm/bin/rvm 2.0.0 do rvm --force gemset empty #{@gemset}"
    @task.namespace.should_receive(:run_without_rvm).with(expected)
    @configuration.execute_task @task
  end

  it "should empty a system-wide gemset" do
    @configuration.set :rvm_type, :system
    @configuration.trigger :load
    expected = <<-EOSHELL.gsub(/^      /, '')
      if id | grep ' groups=.*(rvm)' >/dev/null ;
      then /usr/local/rvm/bin/rvm 2.0.0 do rvm --force gemset empty #{@gemset} ;
      else sudo -p 'sudo password: '  sg rvm -c '/usr/local/rvm/bin/rvm 2.0.0 do rvm --force gemset empty #{@gemset}' ;
      fi
    EOSHELL
    @task.namespace.should_receive(:run_without_rvm).with(expected)
    @configuration.execute_task @task
  end
end

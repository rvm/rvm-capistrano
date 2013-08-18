require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "rvm:install_ruby task" do
  include_context "Capistrano::Configuration"

  before {
    @gemset = 'mygemset'
    @configuration.set :rvm_ruby_string, '2.0.0@' + @gemset
    @task = @configuration.find_task 'rvm:install_ruby'
  }

  it "should install a ruby in $HOME" do
    @configuration.trigger :load
    expected = ' ' + <<-EOSHELL.gsub(/^\s+/, '').gsub("\n", ' ')
      __LAST_STATUS=0;
      export CURL_HOME=\"${TMPDIR:-${HOME}}/.rvm-curl-config.$$\";
      mkdir ${CURL_HOME}/;
      {
        [[ -r ${HOME}/.curlrc ]] && cat ${HOME}/.curlrc;
        echo \"silent\";
        echo \"show-error\";
      } > $CURL_HOME/.curlrc;
      $HOME/.rvm/bin/rvm --autolibs=2 install 2.0.0 ;
      $HOME/.rvm/bin/rvm 2.0.0 do rvm gemset create mygemset || __LAST_STATUS=$?;
      rm -rf $CURL_HOME;
      exit ${__LAST_STATUS}
    EOSHELL
    @configuration.should_receive(:run_without_rvm).with(expected)
    @configuration.execute_task @task
  end

  it "should install a ruby system-wide" do
    @configuration.set :rvm_type, :system
    @configuration.trigger :load
    expected = ' ' + <<-EOSHELL.gsub(/^\s+/, '').gsub("\n", ' ')
      __LAST_STATUS=0;
      export CURL_HOME=\"${TMPDIR:-${HOME}}/.rvm-curl-config.$$\";
      mkdir ${CURL_HOME}/;
      {
        [[ -r ${HOME}/.curlrc ]] && cat ${HOME}/.curlrc;
        echo \"silent\";
        echo \"show-error\";
      } > $CURL_HOME/.curlrc;
      if id | grep ' groups=.*(rvm)' >/dev/null ; then
        /usr/local/rvm/bin/rvm --autolibs=2 install 2.0.0 ;
      else
        sudo -p 'sudo password: ' sg rvm -c '/usr/local/rvm/bin/rvm --autolibs=2 install 2.0.0 ' ;
      fi ;
      if id | grep ' groups=.*(rvm)' >/dev/null ; then
        /usr/local/rvm/bin/rvm 2.0.0 do rvm gemset create mygemset ;
      else
        sudo -p 'sudo password: ' sg rvm -c '/usr/local/rvm/bin/rvm 2.0.0 do rvm gemset create mygemset' ;
      fi || __LAST_STATUS=$?;
      rm -rf $CURL_HOME;
      exit ${__LAST_STATUS}
    EOSHELL
    @configuration.should_receive(:run_without_rvm).with(expected)
    @configuration.execute_task @task
  end
end

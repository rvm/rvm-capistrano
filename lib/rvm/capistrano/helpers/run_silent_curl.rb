require 'rvm/capistrano/base'

rvm_with_capistrano do
  def run_silent_curl(command, options={})
    run_without_rvm(<<-EOF.gsub(/[\s]+/, ' '))
      __LAST_STATUS=0;
      export CURL_HOME="${TMPDIR:-${HOME}}/.rvm-curl-config.$$";
      mkdir ${CURL_HOME}/;
      {
        [[ -r ${HOME}/.curlrc ]] && cat ${HOME}/.curlrc;
        echo "silent";
        echo "show-error";
      } > $CURL_HOME/.curlrc;
      #{command} || __LAST_STATUS=$?;
      rm -rf $CURL_HOME;
      exit ${__LAST_STATUS}
    EOF
  end
end

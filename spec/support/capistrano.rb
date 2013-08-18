require 'capistrano-spec'
require 'capistrano'

RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers
end

shared_context "Capistrano::Configuration" do
  before do
    @configuration = Capistrano::Configuration.new
    $:.unshift File.dirname(__FILE__) + '/../../lib'
    # @configuration.load_paths.unshift File.dirname(__FILE__) + '/../../lib'
    Capistrano::Configuration.instance = @configuration

    # define _cset etc. from capistrano
    @configuration.load 'deploy'

    # load rvm/capistrano/base etc.
    @configuration.require 'rvm/capistrano'

    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
  end
end

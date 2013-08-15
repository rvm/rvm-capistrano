require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "rvm paths" do
  include_context "Capistrano::Configuration"

  describe "default values" do
    before { @configuration.trigger(:load) }

    it "should return default system path" do
      @configuration.fetch(:rvm_system_path).should == '/usr/local/rvm'
    end

    it "should return default user path" do
      @configuration.fetch(:rvm_user_path).should == '$HOME/.rvm'
    end

    it "should return default installation mode" do
      @configuration.fetch(:rvm_type).should == :user
    end

    it "should return default path" do
      @configuration.fetch(:rvm_path).should == '$HOME/.rvm'
    end

    it "should return default bin path" do
      @configuration.fetch(:rvm_bin_path).should == '$HOME/.rvm/bin'
    end
  end

  describe "system mode" do
    before do
      @configuration.set(:rvm_type, :system)
      @configuration.trigger(:load)
    end

    it "should return default path" do
      @configuration.fetch(:rvm_path).should == '/usr/local/rvm'
    end

    it "should return system bin path" do
      @configuration.fetch(:rvm_bin_path).should == '/usr/local/rvm/bin'
    end
  end
end

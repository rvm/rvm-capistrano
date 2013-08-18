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

    it "should return default gemset path" do
      @configuration.fetch(:rvm_gemset_path).should == '$HOME/.rvm/gemsets'
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

    it "should return system gemset path" do
      @configuration.fetch(:rvm_gemset_path).should == '/usr/local/rvm/gemsets'
    end
  end

  describe "invalid configuration values" do
    context "in :mixed mode" do
      before { @configuration.set(:rvm_type, :mixed) }

      it "should abort if rvm_type is :mixed and rvm_user empty" do
        expect { @configuration.trigger(:load) }.to \
          abort_with_error(/When rvm_type is :mixed, you must also set rvm_user/)
      end

      it "should abort if rvm_user isn't an Array" do
        @configuration.set(:rvm_user, "a string")
        expect { @configuration.trigger(:load) }.to \
          abort_with_error(/rvm_user must be an Array/)
      end

      it "should abort if rvm_user contains an invalid value" do
        @configuration.set(:rvm_user, [ :invalid_value ])
        expect { @configuration.trigger(:load) }.to \
          abort_with_error(/Invalid value\(s\) in rvm_user: invalid_value/)
      end

      it "should abort if rvm_user mixes :none with other values" do
        @configuration.set(:rvm_user, [ :none, :gemsets ])
        expect { @configuration.trigger(:load) }.to \
          abort_with_error(/rvm_user cannot mix :none with other values/)
      end

      it "should abort if rvm_user mixes :all with other values" do
        @configuration.set(:rvm_user, [ :gemsets, :all ])
        expect { @configuration.trigger(:load) }.to \
          abort_with_error(/rvm_user cannot mix :all with other values/)
      end
    end

    it "should abort if rvm_user is set and rvm_type isn't :mixed" do
      @configuration.set(:rvm_user, [ :gemsets ])
      expect { @configuration.trigger(:load) }.to \
        abort_with_error(/rvm_user must not be set unless rvm_type is :mixed/)
    end
  end
end

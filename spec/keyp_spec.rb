require 'spec_helper'

describe Keyp do

  context "CONSTANTS" do
    it 'should return correct version string' do
      #Keyp.version_string.should == "Keyp version #{Keyp::VERSION}"
      Keyp::VERSION.should == '0.0.7'
    end

    it 'should specify default store' do
      Keyp::DEFAULT_BAG.should == 'default'
    end

    it "should specifify default store extension" do
      Keyp::DEFAULT_EXT.should == '.yml'
    end

    it 'should specify default keyp dir' do
      Keyp::DEFAULT_KEYP_DIR.should == '.keyp'
    end
  end

  context "Keyp directory" do
    it 'should return correct default keyp dir' do
      # DEFAULT_KEYP_DIRNAME = ENV['KEYP_DIRNAME'] || '.keyp'
      Keyp::home.should == File.join(ENV['HOME'], '.keyp')
    end

    it 'should be able to override default keyp dir'
  end

  context "Bag management" do
    it 'should return default bag' do
      keyper = Keyp::bag
      keyper.name.should == 'default'
    end

    it "should say a bag exists" do
      # get the default bag, should create it if it doesn't exist
      keyper = Keyp::bag
      Keyp.exist?(keyper.name).should == true
    end

    it "should say a bag does not exist" do
      # TODO: add bag name generation to a helper
      bag_name = "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M%S%L")}"
      Keyp.exist?(bag_name).should_not == true
    end

    it "Should rename a bag if new name does not exist (and names are different)"
    it "Should not rename a bag if new name exists"

  end




  # Braindump of tests
  # Should show no keys if empty bag
  # should create default.yml if .keyp already exists but default.yml does not when run from command line
end

require 'spec_helper'

describe Keyp do

  context "CONSTANTS" do
    it 'should return correct version string' do
      #Keyp.version_string.should == "Keyp version #{Keyp::VERSION}"
      Keyp::VERSION.should == '0.0.2'
    end

    it 'should specify default store' do
      Keyp::DEFAULT_STORE.should == 'default'
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
      bag_name = "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M")}"
      Keyp.exist?(bag_name).should_not == true
    end

  end





  it 'should return a key with data member'
  it 'should return a key acting as a hash'
  it 'should allow assigning a key if not read only'
  it 'should not allow assigning a key if read only'
  it 'should set the dirty flag if a new key is created'
  it 'should set the dirty flag if a key is given a new value'
  it 'should not set the dirty flag if a key is assigned a value equal to its existing value'

  # Braindump of tests
  # Should show no keys if empty bag
  # should create default.yml if .keyp already exists but default.yml does not when run from command line
end

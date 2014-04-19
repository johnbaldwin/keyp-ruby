require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Keyp do

  def bag_name_for_testing
    # TODO: pseudo random bag name generation to a helper
    "bring_a_towel_#{Time.now.strftime("%Y%m%d%H%M%S%L")}"
  end

  context 'CONSTANTS' do
    it 'should return correct version string' do
      #Keyp.version_string.should == "Keyp version #{Keyp::VERSION}"
      Keyp::VERSION.should == '0.0.7'
    end

    it 'should specify default store' do
      Keyp::DEFAULT_BAG.should == 'default'
    end

    it 'should specifify default store extension' do
      Keyp::DEFAULT_EXT.should == '.yml'
    end

    it 'should specify default keyp dir' do
      Keyp::DEFAULT_KEYP_DIR.should == '.keyp'
    end
  end

  context 'Default Keyp directory' do
    it 'should return correct default keyp dir' do
      # DEFAULT_KEYP_DIRNAME = ENV['KEYP_DIRNAME'] || '.keyp'
      Keyp::home.should == File.join(ENV['HOME'], '.keyp')
    end
  end

  context 'Alternate Keyp directory' do


    before (:each) do
      @root_tempdir = Dir.mktmpdir
      @temp_keyp_dir = File.join(@root_tempdir,Keyp::DEFAULT_KEYP_DIR)
      ENV['KEYP_HOME'] = @temp_keyp_dir
    end

    it 'should be able to override default keyp dir' do
      puts "ENV['KEYP_HOME']=#{ENV['KEYP_HOME']}"
      keyp_dir = Keyp::setup
      keyp_dir.should == Keyp::home
      keyp_dir.should == @temp_keyp_dir
      Keyp::home.should == ENV['KEYP_HOME']

    end

    #TODO: Keyp::setup should return nil when trying to setup to an existing dir
    # Check if we can describe a method
    after (:each) do
      puts "AFTER called, going to try to delete #{@tempdir}"
      FileUtils.rm_rf @root_tempdir
      ENV['KEYP_HOME'] = nil
    end
  end

  context 'Bag management' do
    it 'should return default bag' do
      keyper = Keyp::bag
      keyper.name.should == 'default'
    end

    it "should say a bag exists" do
      # get the default bag, should create it if it doesn't exist
      keyper = Keyp::bag
      Keyp.exist?(keyper.name).should == true
    end

    it 'should say a bag does not exist' do
      # TODO: add bag name generation to a helper
      bag_name = "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M%S%L")}"
      Keyp.exist?(bag_name).should_not == true
    end

    it 'should rename a bag if new name does not exist (and names are different)'
    it 'should not rename a bag if new name exists'

  end

  context 'Renaming bags' do
    it 'should rename bag if it exists and new name does not'

    it 'should not rename bag if current name does not exist'
    it 'should not rename bag if new name exists'
  end


  # Braindump of tests
  # Should show no keys if empty bag
  # should create default.yml if .keyp already exists but default.yml does not when run from command line
end

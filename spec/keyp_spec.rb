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
  end

  context 'Renaming bags' do
    # NOTE: Yeah, this code and the bag_spec code are redundant
    before (:each) do
      @from_name = bag_name_for_testing
      if Keyp::exist?(@from_name)
        puts "Rename bag, bag #{@from_name} already exists"
      else
        puts "Rename bag, bag #{@from_name} does NOT exist"
      end
      @from_bag = Keyp.create_bag(@from_name)
      sleep(1)
      @to_name = bag_name_for_testing
    end

    it 'should rename bag if it exists and new name does not' do
      bag = @from_bag
      kp = {
          'key1' => 'value1',
          'key2' => 'value2'
      }

      # seed a couple of kv pairs just to keep it a bit real
      # but we should also test with an empty bag
      kp.each {|k,v| bag[k] = v }
      bag.save
      before_meta = {}
      bag.meta.each { |k,v| before_meta[k] = v }
      bag.name.should == @from_name
      @to_name.should_not == @from_name
      result = Keyp.rename_bag(from: @from_name, to: @to_name)
      Keyp.exist?(@from_name).should == false
      Keyp.exist?(@to_name).should == true
      bag = Keyp.bag @to_name
      bag.name.should == @to_name
      bag.meta['name'].should == @to_name
      bag.meta['created_at'].should == before_meta['created_at']
      # Since we are not changing any key pairs, updated_at doesn't change
      bag.meta['updated_at'].should == before_meta['updated_at']
      kp.each do |k,v|
        bag.key?(k).should == true
        bag[k].should == v
      end
    end

    it 'should not rename bag if current name does not exist'
    it 'should not rename bag if new name exists'

    after (:each) do
      Keyp.delete_bag @from_name if Keyp.exist? @from_name
      Keyp.delete_bag @to_name if Keyp.exist? @to_name
    end
  end


  # Braindump of tests
  # Should show no keys if empty bag
  # should create default.yml if .keyp already exists but default.yml does not when run from command line
end

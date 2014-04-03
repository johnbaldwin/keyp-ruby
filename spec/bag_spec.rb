require 'spec_helper'

describe Keyp::Bag do

  context "is empty" do
    before (:each) do
      puts "before : is empty"
      @bag = Keyp::Bag.new 'testing123'
    end

    it "should return an empty hash" do

      @bag.data.size.should == 0
    end
    #it "should have metadata" do
    #  @bag.meta['created_on'].should_not == nil
    #end
  end

  context "is not empty" do
    before (:each) do
      puts "before : is not empty"
      @bag = Keyp::Bag.new 'grue_eats_you'
      @bag['LIGHTS'] = 'out'
    end

    it "should return a non-empty hash" do
      @bag.data.size.should > 0
    end
  end

  context "environment variables" do
    before (:each) do
      # TODO: pseudo random bag name generation to a helper
      bag_name = "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M%S%L")}"
      @bag = Keyp::Bag.new bag_name
    end
    it "should copy all vars"  do
      testvars = {
          'ALPHA' => 'First in the phonetic alphabet',
          'BRAVO' => 'Second in the phonetic alphabet',
          'CHARLIE' => 'Third in the phonetic alphabet'
      }

      testvars.each { |key, value| @bag[key] = value }

      added = @bag.add_to_env
      testvars.each do |key, value|
        ENV[key].should_not == nil
        ENV[key].should == value
      end
    end
  end

  context "bag state" do

    before (:each) do
      # TODO: pseudo random bag name generation to a helper
      bag_name = "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M%S%L")}"
      @bag = Keyp::Bag.new bag_name
    end

    it 'should not set the dirty flag when no items are in the bag' do
      @bag.empty?.should == true
      @bag.dirty.should == false
    end

    it 'should set the dirty flag if a new key is created' do
      @bag['KEY1'] = 'value1'
      @bag.empty?.should == false
      @bag.dirty.should == true

    end

    it 'should not set the dirty flag after save' do
      @bag.empty?.should == true
      @bag['KEY1'] = 'value1'
      @bag.save
      @bag.dirty.should == false
    end
    it 'should set the dirty flag if a key is given a new value' do
      @bag.empty?.should == true
      @bag['KEY1'] = 'value1'
      @bag.dirty.should == true
    end

    it 'should not set the dirty flag if a key is assigned a value equal to its existing value' do
      @bag.empty?.should == true
      @bag['KEY1'] = 'value1'
      @bag.save
      @bag.dirty.should == false
      @bag['KEY1'] = 'value1'
      @bag.dirty.should == false
    end
  end

  it 'should return a key with data member'
  it 'should return a key acting as a hash'
  it 'should allow assigning a key if not read only'
  it 'should not allow assigning a key if read only'
end
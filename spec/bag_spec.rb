require 'spec_helper'

describe Keyp::Bag do

  def bag_name_for_testing
    # TODO: pseudo random bag name generation to a helper
    "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M%S%L")}"
  end

  context "is empty" do
    before (:each) do
      @bag_name = bag_name_for_testing
      @bag = Keyp::Bag.new @bag_name
    end

    it "should return an empty hash" do
      @bag.data.size.should == 0
    end
  end

  context "is not empty" do
    before (:each) do
      @bag_name = bag_name_for_testing
      @bag = Keyp::Bag.new @bag_name
      @bag['LIGHTS'] = 'out'
    end

    it "should return a non-empty hash" do
      @bag.data.size.should > 0
    end
  end

  context "environment variables" do
    before (:each) do
      @bag_name = bag_name_for_testing
      @bag = Keyp::Bag.new @bag_name
    end
    it "should copy all vars"  do
      testvars = {
          'ALPHA' => 'First in the phonetic alphabet',
          'BRAVO' => 'Second in the phonetic alphabet',
          'CHARLIE' => 'Third in the phonetic alphabet',
          '_' => 'a single underscore',
          'a' => 'first letter in the alphabet',
          'bb' => 'two of the second letter in the alphabet'
      }

      testvars.each { |key, value| @bag[key] = value }

      added = @bag.add_to_env
      testvars.each do |key, value|
        ENV[key].should_not == nil
        ENV[key].should == value
      end
    end

    it "should receive all vars" do
      test_keyvals = {
        'foo' => 'bar',
        'biz' => 'baz',
        'GRUE' => 'Eats you in the dark',
        'a' => 'first letter in the alphabet',
        'bb' => 'two of the second letter in the alphabet'
      }

      test_keyvals.each do |key,value|
        ENV[key] = value
      end
      @bag.load_from_env
      ENV.each do |key,value|
        puts "testing key=#{key}"
        @bag.key?(key).should == true
        @bag[key].should == value
      end
    end

    it "should not overwrite existing keys"
    it "should match filtering pattern"
  end

  context "bag state" do

    before (:each) do
      @bag_name = bag_name_for_testing
      @bag = Keyp::Bag.new @bag_name
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

    it 'should allow assigning a key if not read only'
    it 'should not allow assigning a key if read only'
  end

  context "metadata" do

    before (:each) do
      @bag_name = bag_name_for_testing
      @bag = Keyp::Bag.new @bag_name
    end

    it "should have metadata" do
    #  @bag.meta['created_on'].should_not == nil
    end

    it 'Should not update created_at after bag is initially created' do
      created_at = @bag.meta['created_at']
      @bag['foo'] = 'bar'
      @bag.save
      @bag.meta['created_at'].should == created_at
    end

    it 'should update updated_at when bag is saved' do
      updated_at = @bag.meta['updated_at']
      @bag['foo'] = 'bar'
      @bag.save
      @bag.meta['updated_at'].should > updated_at
    end

    it 'Should not update updated_at if bag has not been saved'

  end

  it 'should return a key with data member'
  it 'should return a key acting as a hash'

end
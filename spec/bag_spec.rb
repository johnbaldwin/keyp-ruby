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

    it 'should receive all vars' do
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
        #puts "testing key=#{key}"
        @bag.key?(key).should == true
        @bag[key].should == value
      end
    end

    it 'should not overwrite existing keys'
    it 'should match filtering pattern'
  end

  context 'Bag state' do

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

  context 'Metadata' do

    before (:each) do
      @bag_name = bag_name_for_testing
      @bag = Keyp::Bag.new @bag_name
    end

    it "should have metadata" do
    #  @bag.meta['created_on'].should_not == nil
    end

    it 'should not update created_at after bag is initially created' do
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

    it 'should not update updated_at if bag has not been saved' do
      updated_at = @bag.meta['updated_at']
      @bag['foo'] = 'bar'
      @bag.meta['updated_at'].should == updated_at
    end

    it 'should use metadata for the bag name' do
      def @bag.set_name(name)
        @meta['name'] = name
      end
      test_name = 'norwegian_blue'
      @bag.set_name(test_name)
      @bag.name.should == test_name
    end
  end

  context 'Bag management' do
    before (:each) do
      @from_name = bag_name_for_testing
      @from_bag = Keyp::Bag.new @from_name
      sleep(1)
      @to_name = bag_name_for_testing
    end

    it 'should rename if new name does not exist' do
      bag = @from_bag
      puts "Testing bag rename with from_name #{@from_name}"
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
      # we know the to_name does not exist
      result = bag.rename(@to_name)
      bag.name.should == @to_name
      bag.meta['name'].should == @to_name
      bag.meta['created_at'].should == before_meta['created_at']
      # Since we are not changing any key pairs, updated_at doesn't change
      bag.meta['updated_at'].should == before_meta['updated_at']
      bag.meta['name'].should_not == before_meta['name']
    end

    it 'should not rename if new name exists' do

    end
  end


  it 'should return a key with data member'
  it 'should return a key acting as a hash'

end
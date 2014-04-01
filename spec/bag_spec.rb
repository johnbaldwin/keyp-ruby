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
      bag_name = "grue_eats_you_when_it_is_dark_#{Time.now.strftime("%Y%m%d%H%M")}"
      @bag = Keyp::Bag.new bag_name
    end
    it "should copy all vars"
=begin
    do
      testvars = {
          'ALPHA' => 'First in the phonetic alphabet',
          'BRAVO' => 'Second in the phonetic alphabet',
          'CHARLIE' => 'Third in the phonetic alphabet'
      }

      testvars.each { |key, value| @bag[key] = value }

      @bag.add_to_env
      testvars.each do |key, value|
        ENV[key].should_not == nil
        ENV[key].should == value
      end
    end
=end
  end
end
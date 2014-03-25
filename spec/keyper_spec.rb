require 'spec_helper'

describe Keyp::Keyper do

  context "is empty" do
    before (:each) do
      puts "before : is empty"
      @bag = Keyp::Keyper.new 'testing123'
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
      @bag = Keyp::Keyper.new 'grue_eats_you'
      @bag['LIGHTS'] = 'out'
    end
    it "should return a non-empty hash" do
      @bag.data.size.should > 0
    end
  end
end